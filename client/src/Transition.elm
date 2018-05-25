module Transition
    exposing
        ( Animation
        , State
        , initial
        , queueInitial
        , queueLoading
        , queueNext
        , render
        , subscription
        , update
        )

import Animation
import Animation.Messenger
import Html


type alias State msg =
    Animation.Messenger.State msg


type alias Animation =
    Animation.Msg


initial : State msg
initial =
    Animation.style properties.initial


queueInitial : State msg -> State msg
queueInitial =
    Animation.queue [ animate properties.initial ]


queueLoading : State msg -> State msg
queueLoading =
    Animation.queue [ animate properties.loading ]


queueNext : msg -> State msg -> State msg
queueNext msg =
    Animation.queue [ Animation.Messenger.send msg ]


properties :
    { initial : List Animation.Property
    , loading : List Animation.Property
    }
properties =
    { initial =
        [ Animation.opacity 1.0
        , Animation.translate (Animation.px 0) (Animation.px 0)
        ]
    , loading =
        [ Animation.opacity 0.0
        , Animation.translate (Animation.px 0) (Animation.px 25)
        ]
    }


animate : List Animation.Property -> Animation.Messenger.Step msg
animate =
    Animation.toWith <| Animation.spring { stiffness = 400, damping = 28 }



--


update : Animation -> State msg -> ( State msg, Cmd msg )
update =
    Animation.Messenger.update


render : State msg -> List (Html.Attribute msgB)
render =
    Animation.render


subscription : (Animation -> msg) -> State msg -> Sub msg
subscription msg state =
    Animation.subscription msg [ state ]
