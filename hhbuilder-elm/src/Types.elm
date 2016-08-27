module Types exposing (..)

import Json.Encode as Json
import String


-- MESSAGES


type Msg
    = UpdateAge String
    | UpdateRelationship String
    | UpdateSmoker Bool
    | AddMember
    | RemoveMember Int
    | RenderJSON



-- MODELS


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
    , householdJSON : String
    }


type alias ValidationErrors =
    { age : String
    , relationship : String
    , hasErrors : Bool
    }



-- HELPERS


serializeToJSON household =
    Json.encode 0
        (Json.list
            (List.map
                (\member ->
                    Json.object
                        [ ( "age"
                          , Json.int
                                (String.toInt member.age
                                    |> Result.toMaybe
                                    |> Maybe.withDefault 0
                                )
                          )
                        , ( "relationship", Json.string member.relationship )
                        , ( "smoker", Json.bool member.smoker )
                        ]
                )
                household
            )
        )
