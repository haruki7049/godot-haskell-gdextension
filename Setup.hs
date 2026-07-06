module Main (main) where

import Distribution.Simple (UserHooks, buildHook, defaultMainWithHooks, simpleUserHooks)
import Distribution.Simple.BuildPaths (autogenComponentModulesDir)
import Distribution.Simple.LocalBuildInfo (LocalBuildInfo, withLibLBI)
import Distribution.Simple.Program.Find (defaultProgramSearchPath, findProgramOnSearchPath)
import Distribution.Simple.Setup (BuildFlags)
import Distribution.Simple.Utils
  ( createDirectoryIfMissingVerbose,
    die',
    rawSystemExit,
  )
import Distribution.Types.PackageDescription (PackageDescription)
import Distribution.Verbosity (normal)
import System.Directory (withCurrentDirectory)

main :: IO ()
main =
  defaultMainWithHooks
    simpleUserHooks
      { buildHook = myBuildHook
      }

myBuildHook :: PackageDescription -> LocalBuildInfo -> UserHooks -> BuildFlags -> IO ()
myBuildHook pkgDescr lbi hooks flags = do
  mToolPath <- findProgramOnSearchPath normal defaultProgramSearchPath "godot4"
  toolPath <- case mToolPath of
    Just (p, _) -> return p
    Nothing -> die' normal "godot4 not found on PATH"

  withLibLBI pkgDescr lbi $ \_lib clbi -> do
    let genDir = autogenComponentModulesDir lbi clbi
    createDirectoryIfMissingVerbose normal True genDir
    -- The tool dumps the header into the current directory,
    -- so run it with cwd set to genDir
    withCurrentDirectory genDir $
      rawSystemExit normal toolPath ["--dump-gdextension-interface", "--quiet", "--no-header"]

  buildHook simpleUserHooks pkgDescr lbi hooks flags
