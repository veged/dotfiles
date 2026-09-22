#!/usr/bin/env python3
"""Проверка обнаружения навыков без изменения их инструкций и ресурсов."""
import json
from pathlib import Path
import subprocess
import tempfile
import unittest

SCRIPT = Path(__file__).resolve().parents[1] / 'sync-skill-discovery'


class DiscoveryTest(unittest.TestCase):
    def test_sync_preserves_metadata_and_resources(self):
        with tempfile.TemporaryDirectory(prefix='skill-discovery-') as directory:
            root = Path(directory)
            manifest = root / 'discovery.json'
            manifest.write_text(json.dumps({'user_skills': ['course'], 'plugins': {'kit': ['audit']}}))
            canonical = root / '.agents/skills/course'
            stable = root / '.codex/plugins/dotfiles-local/kit/skills/audit'
            cache = root / '.codex/plugins/cache/dotfiles-local/kit/1.0/skills/audit'
            unrelated = root / '.agents/skills/other'
            for skill in [canonical, stable, cache, unrelated]:
                (skill / 'references').mkdir(parents=True)
                (skill / 'SKILL.md').write_text('Исходная инструкция\n')
                (skill / 'references/input.md').write_text('Исходный ресурс\n')
            projection = root / '.codex/skills/course'
            projection.parent.mkdir(parents=True)
            projection.symlink_to(canonical, target_is_directory=True)
            metadata = canonical / 'agents/openai.yaml'
            metadata.parent.mkdir()
            original = '# сохранить комментарий\ninterface:\n  display_name: "Курс"\ndependencies:\n  tools:\n    - type: mcp\n      value: example\npolicy:\n  allow_implicit_invocation: true\n'
            metadata.write_text(original)
            before = {p: p.read_bytes() for skill in [canonical, stable, cache, unrelated] for p in skill.rglob('*') if p.is_file() and p != metadata}
            command = [str(SCRIPT), '--home', str(root), '--manifest', str(manifest)]
            self.assertEqual(subprocess.run([*command, '--check'], capture_output=True).returncode, 1)
            result = subprocess.run(command, check=True, capture_output=True, text=True)
            self.assertIn('проверено 3', result.stdout)
            for skill in [canonical, stable, cache]:
                data = subprocess.check_output(['yq', '-o=json', '.', str(skill / 'agents/openai.yaml')], text=True)
                self.assertFalse(json.loads(data)['policy']['allow_implicit_invocation'])
            data = json.loads(subprocess.check_output(['yq', '-o=json', '.', str(metadata)], text=True))
            self.assertEqual(data['interface'], {'display_name': 'Курс'})
            self.assertEqual(data['dependencies'], {'tools': [{'type': 'mcp', 'value': 'example'}]})
            self.assertIn('# сохранить комментарий', metadata.read_text())
            self.assertFalse((unrelated / 'agents/openai.yaml').exists())
            self.assertTrue(all(p.read_bytes() == value for p, value in before.items()))
            synced = {p: p.read_bytes() for p in root.rglob('openai.yaml')}
            subprocess.run(command, check=True, capture_output=True)
            self.assertTrue(all(p.read_bytes() == value for p, value in synced.items()))
            subprocess.run([*command, '--check'], check=True, capture_output=True)
            # Обновление пакета вернуло исходные метаданные: повторная синхронизация восстанавливает политику.
            metadata.write_text(original)
            subprocess.run(command, check=True, capture_output=True)
            self.assertEqual(metadata.read_bytes(), synced[metadata])


if __name__ == '__main__':
    unittest.main()
