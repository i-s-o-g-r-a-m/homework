port module State exposing (..)

import String
import Types exposing (..)


-- PORTS


port alert : String -> Cmd msg



-- INIT


init : ( Model, Cmd Msg )
init =
    ( { age = ""
      , relationship = ""
      , smoker = False
      , errors = ValidationErrors "" "" False
      , household = []
      , householdJSON = ""
      }
    , Cmd.none
    )



-- UPDATE


update : Msg -> Model -> ( Model, Cmd msg )
update msg model =
    case msg of
        AddMember ->
            ( let
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
            , Cmd.none
            )

        RemoveMember memberIdx ->
            -- just having fun with map and filter here, hey look we're doing
            -- functional programing, come on, but this isn't readable;
            -- probably you could do this more concisely using Array.slice
            ( let
                updatedHousehold =
                    List.map
                        (\m ->
                            let
                                ( idx, member ) =
                                    m
                            in
                                member
                        )
                        (List.filter
                            (\m ->
                                let
                                    ( idx, _ ) =
                                        m
                                in
                                    idx /= memberIdx
                            )
                            (List.indexedMap (,) model.household)
                        )
              in
                { model | household = updatedHousehold }
            , Cmd.none
            )

        RenderJSON ->
            if List.length model.household == 0 then
                ( model, alert "The household must have at least one member." )
            else
                ( { model | householdJSON = serializeToJSON model.household }, Cmd.none )

        UpdateAge age ->
            ( { model | age = age }, Cmd.none )

        UpdateRelationship relationship ->
            ( { model | relationship = relationship }, Cmd.none )

        UpdateSmoker smoker ->
            ( { model | smoker = smoker }, Cmd.none )



-- UPDATE HELPERS


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



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
