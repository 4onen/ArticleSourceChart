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


type CommandSwitch
    = ToDrag
    | ToAdd
    | ToDelete
    | ToLinking
    | ToUnlinking


type Msg
    = SwitchTo CommandSwitch
    | DrawspaceClick Point
    | Select ArticleId Point
    | ChangeContent ArticleField
    | DragTo Point
