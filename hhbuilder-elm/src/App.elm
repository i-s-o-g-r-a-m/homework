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


type alias Member =
    { age : String
    , relationship : String
    , smoker : Bool
    }


type alias Model =
    { age : String
    , relationship : String
    , smoker : Bool
    , errors : ValidationErrors
    , household : List Member
    }


type alias ValidationErrors =
    { age : String
    , relationship : String
    , hasErrors : Bool
    }


model : Model
model =
    { age = ""
    , relationship = ""
    , smoker = False
    , errors = ValidationErrors "" "" False
    , household = []
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
            let
                updated =
                    { model | errors = validate model }

                newMember =
                    { age = updated.age
                    , relationship = updated.relationship
                    , smoker = updated.smoker
                    }
            in
                if updated.errors.hasErrors then
                    updated
                else
                    { updated
                        | household = updated.household ++ [ newMember ]
                        , age = ""
                        , relationship = ""
                        , smoker = False
                    }

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
                            , input [ type' "text", onInput Age, value model.age ] []
                            ]
                        , span [ style [ ( "color", "red" ) ] ] [ text (" " ++ model.errors.age) ]
                        ]
                    , div []
                        [ label []
                            [ text "Relationship"
                            , text " "
                            , select
                                [ onInput Relationship
                                , value model.relationship
                                ]
                                [ option [ value "" ] [ text "---" ]
                                , option [ value "self" ] [ text "Self" ]
                                , option [ value "spouse" ] [ text "Spouse" ]
                                , option [ value "child" ] [ text "Child" ]
                                , option [ value "parent" ] [ text "Parent" ]
                                , option [ value "grandparent" ] [ text "Grandparent" ]
                                , option [ value "other" ] [ text "Other" ]
                                ]
                            ]
                        , span [ style [ ( "color", "red" ) ] ] [ text (" " ++ model.errors.relationship) ]
                        ]
                    , div []
                        [ label []
                            [ text "Smoker?"
                            , text " "
                            , input [ type' "checkbox", name "smoker", onCheck Smoker, checked model.smoker ] []
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
    let
        age =
            if model.age == "" then
                "age is required"
            else
                case String.toInt (String.trim model.age) of
                    Err msg ->
                        "age must be a number greater than 0"

                    Ok val ->
                        if val < 1 then
                            "age must be a number greater than 0"
                        else
                            ""

        relationship =
            if model.relationship == "" then
                "relationship is required"
            else
                ""
    in
        { age = age
        , relationship = relationship
        , hasErrors = age /= "" || relationship /= ""
        }
