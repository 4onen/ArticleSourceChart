module Linked exposing (Linked, insertLink, removeLink)

import Set exposing (Set)
import ArticleId exposing (ArticleId)


type alias Linked a =
    { a | links : Set ArticleId }


insertLink : ArticleId -> Linked a -> Linked a
insertLink target linkedRecord =
    { linkedRecord | links = Set.insert target linkedRecord.links }


removeLink : ArticleId -> Linked a -> Linked a
removeLink target linkedRecord =
    { linkedRecord | links = Set.remove target linkedRecord.links }
