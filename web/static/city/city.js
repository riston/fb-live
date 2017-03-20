
// Stylesheets
import "./city.css"

// Modules
import "phoenix_html";
import anime from "animejs";
import xs from "xstream";
import throttle from "xstream/extra/throttle";
import socket from "../socket";

const CHANNEL_NAME = "command:lobby";
const MAX_AVATARS = 10;

const select = document.querySelector.bind(document);

// DOM element definition
const right$ = select(".right-count");
const left$ = select(".left-count");

const fbLike$ = select(".fb-like");
const fbLove$ = select(".fb-love");

const fbAvatars$ = select(".fb-avatars");

// Buttons
const controlPanel$ = select(".fb-control");
const leftReactionBtn$ = select(".fb-left-reaction");
const rightReactionBtn$ = select(".fb-right-reaction");
const addAvatarBtn$ = select(".fb-add-avatar");

const avatars = [];

const timeline = anime.timeline({
    autoplay: false,
    loop: false,
});

// Like animation
setInterval(() => {
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
    })
    .play();
}, 10e3);

// Love animation
setInterval(() => {
    anime({
        targets: fbLove$,
        scale: 1.5,
        easing: "easeInOutBack",
        duration: 1e3,
        direction: "alternate",
    });
}, 15e3);

// Display debug console if enabled
if (window.localStorage.getItem("debug")) {
  controlPanel$.style.display = "block";
}

const bounceCounterAnim = targets => anime({
    targets,
    scale: 1.5,
    easing: "easeOutExpo",
    duration: 150,
    direction: "alternate",
    autoplay: false,
});

const avatarVisibleAnim = targets => anime({
    targets,
    opacity: 1,
    easing: "easeInOutBack",
    duration: 1e3,
});

const avatarRemoveAnim = (targets, onComplete) => anime({
    targets,
    translateY: 50,
    opacity: 0,
    duration: 700,
    complete: onComplete,
})

const onSummary = summary => {
  const { error, like, love } = summary;
  if (error) {
      console.error(error);
      return;
  }

  left$.textContent = like;
  right$.textContent = love;
};

const onReaction = reaction => {
  console.log(reaction);
  const { type } = reaction;
  if (type === "like") {
    bounceCounterAnim(left$).play();
  }

  if (type === "love") {
    bounceCounterAnim(right$).play();
  }
};

const onAvatar = avatar => {
  const { user_id, url } = avatar;

  const avatarImg = new Image();
  avatarImg.onload = () => {

    if (avatars.length >= MAX_AVATARS) {
      const avatarToRemove = avatars.shift();
      const onComplete = () => {
        fbAvatars$.removeChild(avatarToRemove);
      };

      avatarRemoveAnim(avatarToRemove, onComplete).play();
    }

    fbAvatars$.appendChild(avatarImg);
    avatarVisibleAnim(avatarImg).play();

    avatars.push(avatarImg);
  };

  avatarImg.height = 50;
  avatarImg.width = 50;
  avatarImg.style.opacity = 0;

  avatarImg.src = url;
};

const onOK = response => console.log("Joined successfully", response);
const onError = response => console.log("Unable to join ", response);

// Now that you are connected, you can join channels with a topic:
const channel = socket.channel(CHANNEL_NAME, {});
channel.join()
  .receive("ok", onOK)
  .receive("error", onError);

channel.on("summary", onSummary);

const reactionStream = xs.create({
  start(listener) {
    channel.on("reaction", x => listener.next(x));
  },
  stop() {}
})
.compose(throttle(250));

reactionStream.addListener({ 
  next: onReaction,
  stop: () => console.log("Reaction animating stopped"),
});

const avatarStream = xs.create({
  start(listener) {
    channel.on("avatar", x => {
      console.log("Avatar received", x);
      listener.next(x);
    });
  },
  stop() {}
})
.compose(throttle(250));

avatarStream.addListener({ 
  next: onAvatar,
  stop: () => console.log("Avatar animating stopped"),
});

addAvatarBtn$.addEventListener("click", () => {
    avatarStream.shamefullySendNext({
        user_id: "xsxsadafds",
        url: "http://lorempixel.com/50/50",
    });
});