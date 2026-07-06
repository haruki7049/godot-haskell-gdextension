{-# LANGUAGE ForeignFunctionInterface #-}

module GodotApi where

import Foreign
import Foreign.C

type GDExtensionInitializationLevel = CInt
type GDExtensionInitializeCallback = Ptr () -> GDExtensionInitializationLevel -> IO ()
type GDExtensionDeinitializeCallback = Ptr () -> GDExtensionInitializationLevel -> IO ()

foreign import ccall "wrapper"
    mkInitializeCallback :: GDExtensionInitializeCallback -> IO (FunPtr GDExtensionInitializeCallback)

foreign import ccall "wrapper"
    mkDeinitializeCallback :: GDExtensionDeinitializeCallback -> IO (FunPtr GDExtensionDeinitializeCallback)

-- Setup GDExtensionInitialization struct
setupInitialization :: Ptr () -> GDExtensionInitializeCallback -> GDExtensionDeinitializeCallback -> IO ()
setupInitialization initializationPtr initCb deinitCb = do
    initFunPtr <- mkInitializeCallback initCb
    deinitFunPtr <- mkDeinitializeCallback deinitCb

    -- offset 0: minimum_initialization_level (3 = Scene)
    pokeByteOff initializationPtr 0 (3 :: CInt)
    -- offset 8: userdata
    pokeByteOff initializationPtr 8 nullPtr
    -- offset 16: initialize
    pokeByteOff initializationPtr 16 initFunPtr
    -- offset 24: deinitialize
    pokeByteOff initializationPtr 24 deinitFunPtr
