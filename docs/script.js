function toggleMenu(){
  let menu = document.querySelector('aside')
  menu.classList.toggle('open')

  let headerMenuButton = document.querySelector('header .open')
  let closeHeaderMenuButton = document.querySelector('header .close-button')
  if (menu.classList.contains('open')){
    headerMenuButton.classList.add('hide')
    closeHeaderMenuButton.classList.add('show')
  }
  else{
    headerMenuButton.classList.remove('hide')
    closeHeaderMenuButton.classList.remove('show')
  }
}