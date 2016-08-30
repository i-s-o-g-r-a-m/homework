module Main exposing (..)

import Debug
import Html exposing (..)
import Html.App as Html
import Html.Attributes exposing (..)
import Html.Events exposing (onCheck, onInput)
import CustomEvents exposing (onClickNoSubmit)


main =
    Html.beginnerProgram { model = model, view = view, update = update }



-- MODEL


type alias Model =
    { age : String
    , relationship : String
    , smoker : Bool
    }


model : Model
model =
    { age = "", relationship = "", smoker = False }



-- UPDATE


type Msg
    = Age String
    | Relationship String
    | Smoker Bool
    | AddMember


update : Msg -> Model -> Model
update msg model =
    case msg of
        AddMember ->
            model

        Age age ->
            { model | age = age }

        Relationship relationship ->
            { model | relationship = relationship }

        Smoker smoker ->
            { model | smoker = smoker }



-- VIEW


view : Model -> Html Msg
view model =
    let
        _ =
            Debug.log "model" model
    in
        div []
            [ h1 [] [ text "Household builder" ]
            , div [ class "builder" ]
                [ ol [ class "household" ] []
                , Html.form
                    []
                    [ div []
                        [ label []
                            [ text "Age"
                            , text " "
                            , input [ type' "text", onInput Age ] []
                            ]
                        ]
                    , div []
                        [ label []
                            [ text "Relationship"
                            , text " "
                            , select [ onInput Relationship ]
                                [ option [ value "" ] [ text "---" ]
                                , option [ value "self" ] [ text "Self" ]
                                , option [ value "spouse" ] [ text "Spouse" ]
                                , option [ value "child" ] [ text "Child" ]
                                , option [ value "parent" ] [ text "Parent" ]
                                , option [ value "grandparent" ] [ text "Grandparent" ]
                                , option [ value "other" ] [ text "Other" ]
                                ]
                            ]
                        ]
                    , div []
                        [ label []
                            [ text "Smoker?"
                            , text " "
                            , input [ type' "checkbox", name "smoker", onCheck Smoker ] []
                            ]
                        ]
                    , div []
                        [ button [ class "add", onClickNoSubmit AddMember ] [ text "add" ]
                        ]
                    , div []
                        [ button [ type' "submit" ] [ text "submit" ]
                        ]
                    ]
                ]
            , pre [ class "debug" ] []
            ]



{-
   viewValidation : Model -> Html msg
   viewValidation model =
       let
           ( color, message ) =
               if model.password == model.passwordAgain then
                   ( "green", "OK" )
               else
                   ( "red", "Passwords do not match!" )
       in
           div [ style [ ( "color", color ) ] ] [ text message ]
-}
