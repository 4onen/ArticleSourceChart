module LoadTabModel exposing (..)

type Model
    = Root
    | CopyPaste String

type Msg 
    = ButtonNew
    | ButtonCopyPaste
    | ButtonFileUpload
    | ButtonDrive
    | ButtonToRoot