module Main (main) where

import Distribution.Simple
import Distribution.Simple.LocalBuildInfo (buildDir)
import System.Directory (copyFile, createDirectoryIfMissing)
import System.FilePath ((</>))

main :: IO ()
main =
  defaultMainWithHooks
    simpleUserHooks
      { postBuild = \_ _ _ lbi -> do
          -- Define the destination directory
          let outDir = ".." </> ".." </> "example" </> "godot" </> "bin"
          createDirectoryIfMissing True outDir

          -- Define source and destination file paths
          let srcLib = buildDir lbi </> "gdext-example" </> "libgdext-example.so"
          let destLib = outDir </> "libgdext-example.so"

          -- Copy the shared library
          copyFile srcLib destLib
      }
