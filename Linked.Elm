module Linked exposing (..)

import Set exposing (Set)

type alias ArticleId = Int

type alias Linked a =
    { a | links : Set ArticleId }

insertLink : ArticleId -> Linked a -> Linked a
insertLink target linkedRecord =
    { linkedRecord | links = Set.insert target linkedRecord.links }


removeLink : ArticleId -> Linked a -> Linked a
removeLink target linkedRecord =
    { linkedRecord | links = Set.remove target linkedRecord.links }