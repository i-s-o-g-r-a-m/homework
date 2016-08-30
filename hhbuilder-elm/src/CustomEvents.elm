module CustomEvents exposing (..)

import Html.Events exposing (onClick, onWithOptions)
import Json.Decode as Json


onClickNoSubmit message =
    onWithOptions "click"
        { preventDefault = True, stopPropagation = False }
        (Json.succeed message)
