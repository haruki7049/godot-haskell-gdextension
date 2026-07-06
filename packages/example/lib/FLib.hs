{-# LANGUAGE ForeignFunctionInterface #-}

module FLib where

import Foreign
import Foreign.C
import GodotApi

-- Implementation of callbacks
initialize :: GDExtensionInitializeCallback
initialize _ level = putStrLn $ "Haskell Extension: initialize called with level " ++ show level

deinitialize :: GDExtensionDeinitializeCallback
deinitialize _ level = putStrLn $ "Haskell Extension: deinitialize called with level " ++ show level

-- Entry point
godot_ext_init :: Ptr () -> Ptr () -> Ptr () -> IO CBool
godot_ext_init _ _ initializationPtr = do
  putStrLn "Hello Haskell Extension! (Initialization started)"
  setupInitialization initializationPtr initialize deinitialize
  return 1

foreign export ccall
  godot_ext_init ::
    Ptr () -> Ptr () -> Ptr () -> IO CBool
