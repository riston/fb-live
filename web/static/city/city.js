
// Stylesheets
import "./city.css"

// Modules
import "phoenix_html";
import socket from "../socket";
import anime from "animejs";

// DOM element definition
const right$ = document.querySelector(".right-count");
const left$ = document.querySelector(".left-count");

const fbLike$ = document.querySelector(".fb-like");
const fbLove$ = document.querySelector(".fb-love");

const fbAvatars$ = document.querySelector(".fb-avatars");

const timeline = anime.timeline({
    autoplay: true,
    loop: true,
});

timeline
.add({
    targets: fbLike$,
    scaleX: [ 
        { value: 1.5 }, 
        { value: 1 },
    ],
    easing: "easeOutExpo",
    duration: 1e3,
})
.add({
    targets: fbLike$,
    scaleY: [
        { value: 1.5 }, 
        { value: 1 },
    ],
    easing: "easeOutExpo",
    duration: 1e3,
    delay: 10e3,
});

anime({
    targets: fbLove$,
    scale: 1.5,
    easing: "easeInOutBack",
    duration: 1e3,
    delay: 5e3,
    loop: true,
    direction: "alternate",
});

const bounceCounter = target => anime({
    targets: target,
    scale: 1.5,
    easing: "easeOutExpo",
    duration: 150,
    direction: "alternate",
    autoplay: false,
});

// window.setInterval(() => bounce(right$).play(), 1e3);