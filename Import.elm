module Import exposing (importChart)

import EditTabModel exposing (Model)
import EditTab

importChart : String -> Model
importChart str =
    EditTab.init