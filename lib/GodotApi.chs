{# context prefix = "GDExtension" #}

module GodotApi where

#include "gdextension_interface.h"

import Foreign.C.String (CString)
import Foreign.C.Types (CUChar)

--
-- All Enums
--

{# enum VariantType {} #}

{# enum VariantOperator {} #}

{# enum CallErrorType {} #}

{# enum ClassMethodFlags {} #} -- TODO this is a bit field!

{# enum ClassMethodArgumentMetadata {} #}

{# enum InitializationLevel {} #}

--
-- All Structs
--

data GodotVersion = GodotVersion {
  major :: Int,
  minor :: Int,
  patch :: Int,
  string :: String
}

--
-- All pointers
--

{# pointer GDExtensionInterfaceFunctionPtr as FunPtr #}

--
-- All Function pointer types
--

{# pointer GDExtensionInterfaceGetProcAddress as GetProcAddressFunPtr #}
{# pointer GDExtensionClassLibraryPtr as ClassLibraryPtr #}
{# pointer *InitializationFunction as InitializationPtr -> FunPtr #}

foreign import ccall "dynamic"
  callGetProcAddress :: GetProcAddressFunPtr -> (CString -> IO (FunPtr))

foreign export ccall "my_extension_init"
  myExtensionInit
    :: GetProcAddressFunPtr
    -> ClassLibraryPtr
    -> InitializationPtr
    -> IO CUChar

myExtensionInit :: GetProcAddressFunPtr -> ClassLibraryPtr -> InitializationPtr -> IO CUChar
myExtensionInit getProcAddress library initialization = do
  -- initialize your extension here
  return 1
