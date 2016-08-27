module View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onCheck, onClick, onInput, onWithOptions)
import Json.Decode as Json
import Types exposing (..)


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Household builder" ]
        , div [ class "builder" ]
            [ ol [ class "household" ] (renderHousehold model)
            , Html.form
                []
                [ div []
                    [ label []
                        [ text "Age"
                        , text " "
                        , input [ type' "text", onInput UpdateAge, value model.age ] []
                        ]
                    , span [ style [ ( "color", "red" ) ] ] [ text (" " ++ model.errors.age) ]
                    ]
                , div []
                    [ label []
                        [ text "Relationship"
                        , text " "
                        , select
                            [ onInput UpdateRelationship
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
                        , input [ type' "checkbox", name "smoker", onCheck UpdateSmoker, checked model.smoker ] []
                        ]
                    ]
                , div []
                    [ button [ class "add", onClickNoSubmit AddMember ] [ text "add" ]
                    ]
                , div []
                    [ button [ type' "submit", onClickNoSubmit RenderJSON ] [ text "submit" ]
                    ]
                ]
            ]
        , pre [ class "debug" ] [ text model.householdJSON ]
        ]


renderHousehold : Model -> List (Html Msg)
renderHousehold model =
    List.indexedMap
        (\idx member ->
            let
                memberInfo =
                    member.relationship
                        ++ " / age "
                        ++ member.age
                        ++ " / "
                        ++ (if member.smoker then
                                "smoker"
                            else
                                "non-smoker"
                           )
                        ++ " "
            in
                li []
                    [ text memberInfo
                    , button [ onClick (RemoveMember idx) ] [ text "remove" ]
                    ]
        )
        model.household



-- CUSTOM EVENTS


onClickNoSubmit message =
    onWithOptions "click"
        { preventDefault = True, stopPropagation = False }
        (Json.succeed message)
