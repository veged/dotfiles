on run argv
  set sourcePath to item 1 of argv
  set pptxPath to item 2 of argv
  set pdfPath to item 3 of argv
  set imagesPath to item 4 of argv
  set sourceFile to POSIX file sourcePath
  set pptxFile to POSIX file pptxPath
  set pdfFile to POSIX file pdfPath
  set imagesFile to POSIX file imagesPath

  with timeout of 600 seconds
    tell application "Keynote"
      set sourceDocument to missing value
      try
        set applicationVersion to version
        set sourceDocument to open sourceFile
        set sourceSlideCount to count of slides of sourceDocument

        export sourceDocument as Microsoft PowerPoint to pptxFile with properties {skipped slides:true}
        export sourceDocument as PDF to pdfFile with properties {skipped slides:true}
        export sourceDocument as slide images to imagesFile with properties {image format:PNG, skipped slides:true, all stages:false}
        close sourceDocument saving no
      on error errorMessage number errorNumber
        if sourceDocument is not missing value then close sourceDocument saving no
        error errorMessage number errorNumber
      end try
    end tell
  end timeout

  return applicationVersion & linefeed & sourceSlideCount
end run
