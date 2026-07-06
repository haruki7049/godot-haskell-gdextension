{-# LANGUAGE ForeignFunctionInterface #-}

module FLib where

import Foreign
import Foreign.C

-- 1. 型の定義
type GDExtensionInitializationLevel = CInt

type GDExtensionInitializeCallback = Ptr () -> GDExtensionInitializationLevel -> IO ()

type GDExtensionDeinitializeCallback = Ptr () -> GDExtensionInitializationLevel -> IO ()

-- 2. Haskellの関数をCの関数ポインタ(FunPtr)に変換するラッパー
foreign import ccall "wrapper"
  mkInitializeCallback :: GDExtensionInitializeCallback -> IO (FunPtr GDExtensionInitializeCallback)

foreign import ccall "wrapper"
  mkDeinitializeCallback :: GDExtensionDeinitializeCallback -> IO (FunPtr GDExtensionDeinitializeCallback)

-- 3. 実際のコールバック関数の実装
initialize :: GDExtensionInitializeCallback
initialize _ level = putStrLn $ "Haskell Extension: initialize called with level " ++ show level

deinitialize :: GDExtensionDeinitializeCallback
deinitialize _ level = putStrLn $ "Haskell Extension: deinitialize called with level " ++ show level

-- 4. エントリポイントのエクスポート
foreign export ccall
  godot_ext_init ::
    Ptr () -> Ptr () -> Ptr () -> IO CBool

-- 5. エントリポイントの実装
godot_ext_init :: Ptr () -> Ptr () -> Ptr () -> IO CBool
godot_ext_init _ _ initializationPtr = do
  putStrLn "Hello Haskell Extension! (Initialization started)"

  -- コールバック関数のポインタを生成
  initFunPtr <- mkInitializeCallback initialize
  deinitFunPtr <- mkDeinitializeCallback deinitialize

  -- GDExtensionInitialization 構造体へポインタを書き込む
  -- x86_64環境のC言語ABIに基づくオフセット計算（パディング考慮）
  -- 構造体の順序: minimum_initialization_level, userdata, initialize, deinitialize
  pokeByteOff initializationPtr 0 (3 :: CInt) -- offset 0:  minimum_initialization_level (3 = Scene)
  pokeByteOff initializationPtr 8 nullPtr -- offset 8:  userdata (ポインタのため8バイト境界へパディングされる)
  pokeByteOff initializationPtr 16 initFunPtr -- offset 16: initialize
  pokeByteOff initializationPtr 24 deinitFunPtr -- offset 24: deinitialize
  return 1
