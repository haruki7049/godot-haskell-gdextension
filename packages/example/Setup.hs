module Main (main) where

import Distribution.Simple
import Distribution.Simple.Hpc (pathsToLibsArtifacts)
import Distribution.Simple.LocalBuildInfo (allComponentsInBuildOrder)

main :: IO ()
main =
  defaultMainWithHooks
    simpleUserHooks
      { postBuild = \args buildFlags pkgDesc lbi -> do
          let clbis = allComponentsInBuildOrder lbi
          mapM_ (\clbi -> print clbi) clbis
      }
