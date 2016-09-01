module Main exposing (..)

import Debug
import Html exposing (..)
import Html.App as Html
import Html.Attributes exposing (..)
import Html.Events exposing (onCheck, onInput)
import String
import CustomEvents exposing (onClickNoSubmit)


main =
    Html.beginnerProgram { model = model, view = view, update = update }



-- MODEL


type alias Model =
    { age : String
    , relationship : String
    , smoker : Bool
    , errors : ValidationErrors
    }


type alias ValidationErrors =
    { age : String
    , relationship : String
    }


model : Model
model =
    { age = ""
    , relationship = ""
    , smoker = False
    , errors = { age = "", relationship = "" }
    }



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
            { model | errors = validate model }

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
            Debug.log "rendering view with" model
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


validate : Model -> ValidationErrors
validate model =
    { age =
        if model.age == "" then
            "Age is required"
        else
            case String.toInt (String.trim model.age) of
                Err msg ->
                    "Age must be a number greater than 0"

                Ok val ->
                    if val < 1 then
                        "Age must be a number greater than 0"
                    else
                        ""
    , relationship =
        if model.relationship == "" then
            "Relationship is required"
        else
            ""
    }



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
