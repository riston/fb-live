
import "phoenix_html";

import {TimelineMax, TweenMax, Power2} from "gsap";
import xs from "xstream";
import throttle from "xstream/extra/throttle";
import socket from "./socket";

const CHANNEL_NAME = "command:lobby";
const MAX_AVATARS = 10;

const bounceAnimation = element => {
  const tl = new TimelineMax()
    .to(element, 0.3, { yoyo: true, scaleX: 2, scaleY: 2 })
    .to(element, 0.3, { yoyo: true, scaleX: 1, scaleY: 1 });

  return tl;
};

// DOM element definition
const right$ = document.querySelector(".right-count");
const left$ = document.querySelector(".left-count");

const fbLike$ = document.querySelector(".fb-like");
const fbLove$ = document.querySelector(".fb-love");

const fbAvatars$ = document.querySelector(".fb-avatars");
const avatars = [];

const pulse = new TimelineMax({
  delay: 5, repeatDelay: 3, repeat: -1
});
pulse
  .to(fbLove$, 1, { opacity: 0 })
  .to(fbLove$, 1, { opacity: 1 })
  .to(fbLike$, 1, { rotation: 30 })
  .to(fbLike$, 1, { rotation: 0 })
  .play();

const onSummary = summary => {
  const { like, love } = summary;

  left$.textContent = like;
  right$.textContent = love;
};

const onReaction = reaction => {
  console.log(reaction);
  const { type } = reaction;
  if (type === "like") {
    bounceAnimation(left$).play();
  }

  if (type === "love") {
    bounceAnimation(right$).play();
  }
};

const onAvatar = avatar => {
  const { user_id, url } = avatar;

  const avatarImg = new Image();
  avatarImg.onload = () => {

    if (avatars.length >= MAX_AVATARS) {
      const avatarToRemove = avatars.shift();
      TweenMax.to(avatarToRemove, 1, {
        bottom: "100px",
        opacity: 0,
        onComplete: () => fbAvatars$.removeChild(avatarToRemove),
      });
    }

    fbAvatars$.appendChild(avatarImg);

    TweenMax.to(avatarImg, 0.5, {
      opacity: 1,
      ease: Power2.easeInOut
    });

    avatars.push(avatarImg);
  };

  avatarImg.height = 50;
  avatarImg.width = 50;
  avatarImg.style.opacity = 0;

  avatarImg.src = url;
  console.log(avatar);  
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
