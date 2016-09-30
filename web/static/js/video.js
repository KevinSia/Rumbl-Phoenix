import Player from "./player"

let Video = {
  init(socket, element){
    if(!element){ return }
    let playerId = element.getAttribute("data-player-id")
    let videoId = element.getAttribute("data-id")

    // connect to the socket
    socket.connect()

    // start the player
    Player.init(element.id, playerId, () => {
      // run the callback (which joins the channel) once the video is ready
      this.onReady(videoId, socket)
    })

  },

  onReady(videoId, socket){
    let msgContainer = document.getElementById("msg-container")
    let msgInput = document.getElementById("msg-input")
    let postButton = document.getElementById("msg-submit")
    // creaing a new channel
    let vidChannel = socket.channel("video:" + videoId)

    // setting up client-side event listener
    postButton.addEventListener("click", e => {
      console.log("pressed button")

      let payload = { body: msgInput.value, at: Player.getCurrentTime() }
      // payload will become params in phoenix's channel
      vidChannel.push("new_annotation", payload)
        .receive("error", e => console.log(e))

      // clean the text_field once event is pushed to server
      msgInput.value = ""
    })

    // setting up server-side event listeners
    vidChannel.on("new_annotation", (resp) => {
      this.renderAnnotation(msgContainer, resp)
    })

    // Join the vid channel
    vidChannel.join()
      .receive("ok", ({annotations}) => {
        // render annotations once joined channel
        msgContainer.innerHTML = ""
        this.scheduleMessages(msgContainer, annotations)
        // annotations.forEach(ann => this.renderAnnotation(msgContainer, ann))
      })
      .receive("error", reason => { console.log("Unable to join", reason) })

  },

  esc(str){
    let div = document.createElement("div")
    div.appendChild(document.createTextNode(str))
    return div.innerHTML
  },

  renderAnnotation(msgContainer, {user, body, at}){
    console.log("creating template")
    let template = document.createElement("div")

    template.innerHTML = `
      <a href="#" data-seek="${this.esc(at)}">
        [${this.formatTime(at)}]
        <b>${this.esc(user.username)}</b>: ${this.esc(body)}
      </a>
    `

    msgContainer.appendChild(template)
    msgContainer.scrollTop = msgContainer.scrollHeight
  },

  // check for remaining messages every second
  scheduleMessages(msgContainer, annotations){
    setTimeout(() => {
      let time = Player.getCurrentTime();
      let remainingMsg = this.renderAtTime(time, msgContainer, annotations)
      this.scheduleMessages(msgContainer, remainingMsg)
    }, 1000)
  },

  renderAtTime(time, msgContainer, annotations){
    return annotations.filter(ann => {
      if(ann.at > time){
        return true
      }
      else{
        this.renderAnnotation(msgContainer, ann)
        return false
      }
    })
  },

  formatTime(at){
    let date = new Date(null)
    if(at === undefined){ at = 0 }
    date.setSeconds(at / 1000)
    return date.toISOString().substr(14, 5)
  }
}

export default Video
