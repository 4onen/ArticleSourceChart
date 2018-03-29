module EditTabModel exposing (..)

import Dict exposing (Dict)

import Point exposing (Point)
import Drag exposing (Drag)
import Linked exposing (Linked)

type alias ArticleId = Int
type alias URL = String

type alias Article = 
    { pos : Point
    , headline : String
    , author : String 
    , link : URL
    }

type alias JavascriptLinked a =
    { a | links : List Int }

type ArticleField
    = Headline String
    | Author String
    | Link URL

type alias Model = 
    { articles : Dict Int (Linked Article)
    , command : Command 
    , nextId : ArticleId
    , chartName : String 
    }

type Msg
    = NameChange String
    | SwitchTo CommandSwitch
    | DrawspaceClick Point
    | Select ArticleId Point
    | ChangeContent ArticleField
    | DragTo Point

type Command
    = Dragging (Maybe Drag)
    | Add (Maybe ArticleId)
    | Delete
    | Linking (Maybe ArticleId)
    | Unlinking (Maybe ArticleId)
    | Exporting ExportModel

type alias ExportModel =
    { previousCommand : Command }

type CommandSwitch
    = ToDrag
    | ToAdd
    | ToDelete
    | ToLinking
    | ToUnlinking
    | ToExporting