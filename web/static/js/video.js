import Player from "./player"

let Video = {
  init(socket, element){
    if(!element){ return }
    let playerId = element.getAttribute("data-player-id")
    let videoId = element.getAttribute("data-id")

    // connect to the socket
    socket.connect()

    // start the player
    Player.init(element.id, player.id, () => {
      // run the callback (which joins the channel) once the video is ready
      this.onReady(videoId, socket)
    })

  },

  onReady(videoId, socket){
    let msgContainer = document.getElementById("msg-container")
    let msgInput = document.getElementById("msg-input")
    let postButton = document.getElementById("msg-submit")
    let vidChannel = socket.channel("videos:" + videoId)
    // Join the vid channel
  }
}

export default Video
