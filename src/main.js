reloadPosts()
window.setInterval(reloadPosts, 1000)

function reloadPosts() {
    var xmlHttp = new XMLHttpRequest()
    xmlHttp.onreadystatechange = () => {
        if(xmlHttp.readyState == 4 && xmlHttp.status == 200) {
            var posts = JSON.parse(xmlHttp.responseText)

            var timeline = document.getElementById("timeline")
            timeline.innerHTML = ""

            posts.forEach((post) => {
                var message = document.createElement("div")
                message.className = "message"
                
                var title = document.createElement("div")
                title.className = "title"
                title.innerText = post.title

                var content = document.createElement("div")
                content.className = "content"
                content.innerText = post.content

                message.appendChild(title)
                message.appendChild(content)
                timeline.insertBefore(message, timeline.firstChild)
            })
        }
    }

    xmlHttp.open("GET", "http://localhost:8080/getposts", true)
    xmlHttp.send(null)
}