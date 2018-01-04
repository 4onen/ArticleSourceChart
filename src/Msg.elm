module Msg exposing (..)

import Point exposing (Point)
import Drag exposing (Drag)
import Article exposing (ArticleField(..))
import ArticleId exposing (ArticleId)


type Command
    = Dragging (Maybe Drag)
    | Add (Maybe ArticleId)
    | Delete
    | Linking (Maybe ArticleId)
    | Unlinking (Maybe ArticleId)
    | Exporting ExportModel


type alias ExportModel =
    { previousCommand : Command
    , copyResult : Maybe Bool
    }


type CommandSwitch
    = ToDrag
    | ToAdd
    | ToDelete
    | ToLinking
    | ToUnlinking
    | ToExporting


type Msg
    = NameChange String
    | SwitchTo CommandSwitch
    | DrawspaceClick Point
    | Select ArticleId Point
    | ChangeContent ArticleField
    | DragTo Point
