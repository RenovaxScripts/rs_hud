window.addEventListener('message',(e)=>{
  const {action,data}=e.data||{}
  if(!action) return
  if(action==='character') applyCharacter(data)
  if(action==='vehicle')   applyVehicle(data)
  if(action==='voice')     applyVoice(data)
})

function setRing(key, v, hideWhenZero){
  const tile = document.querySelector(`.tile[data-key="${key}"]`)
  if(!tile) return
  const p = Math.max(0, Math.min(1, v||0))
  tile.style.setProperty('--p', p)
  if(hideWhenZero) tile.classList.toggle('hidden', p<=0)
}

function applyCharacter(d){
  setRing('hp',      d.hp,      false)
  setRing('armor',   d.armor,   true) 
  setRing('hunger',  d.hunger,  false)  
  setRing('drink',   d.drink,   false) 
  setRing('stamina', d.stamina, false)
}

function applyVoice(d) {
  const tile = document.querySelector('.tile.voice')
  if (!tile) return
  const p = Math.max(0, Math.min(1, d.level ?? 0.33))
  tile.style.setProperty('--p', p)
  tile.classList.toggle('talking', !!d.talking)
  const icon = document.getElementById('voiceIcon')
  if (icon) icon.src = d.radio ? 'icons/radio.svg' : 'icons/mic.svg'
}


function applyVehicle(d){
  const root = document.getElementById('vehicle')
  if(!root) return
  if(!d.show){ root.classList.add('hidden'); return }
  root.classList.remove('hidden')

  const cPrev = document.getElementById('cPrev')
  const cCur  = document.getElementById('cCur')
  const cNext = document.getElementById('cNext')
  if(d.compass){
    cPrev.textContent = d.compass.prev || ''
    cCur.textContent  = d.compass.cur  || ''
    cNext.textContent = d.compass.next || ''
  }

  document.getElementById('speedBig').textContent = d.speed || 0
  document.getElementById('unitBig').textContent  = d.unit  || 'km/h'
  document.getElementById('rpmTxt').textContent   = Math.floor((d.rpm||0)*8000)

  const pct = Math.max(0, Math.min(100, Math.round((d.fuel||0)*100)))
  document.getElementById('fuelPct').textContent  = pct + '%'
  document.getElementById('fuelFill').style.width = pct + '%'
  
  const parts = (d.street||'').split(' / ')
  document.getElementById('streetTop').textContent    = parts[0] || '—'
  document.getElementById('streetBottom').textContent = parts[1] || ''
}
