module App exposing (main)

import Html.App as App
import View exposing (..)
import State exposing (..)
import Types exposing (..)


main : Program Never
main =
    App.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
