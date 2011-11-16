module AsakusaSatellite
open util/ordering[System]
// ------------------------------
// models for AsakusaSatellite
// ------------------------------
sig ID{}
sig System {
  rooms : set Room
}

sig Room {
   id : one ID,
   messages : Message,
   owner : one User,
   members : set User
} {
  not ( owner in members)
}

sig PublicRoom, PrivateRoom extends Room{}
sig User {}
sig Message {
   id : one ID
}

fact room_join {
      all r : Room | some s : System | r in s.rooms
}

// ---------------------
// access rights
// ---------------------
pred access(room : Room, user : User) {
  (room in PublicRoom) or (user in room.owner) or (user in  room.members)
}

// ---------------------
// operation
// ---------------------
pred addRoom(s,s' : System, room : Room, user : User) {
   no room.members
   room.owner = user
   s'.rooms = s.rooms + room
}

pred delRoom(s, s' : System, room : Room, user : User) {
   s'.rooms = s.rooms - room
}

fun lsRoom(s : System, user : User) : set Room {
  { room : Room | room in s.rooms and access[room, user] }
}

pred addMember(r, r' : Room, member, user : User) {
   access[r, user]
   r'.id = r.id
   r'.members = r.members + member
}

pred delMember(r, r' : Room, member, user : User) {
   access[r, user]
   r'.id = r.id
   r'.members = r.members - member
}

pred addMessage(r, r' : Room, m : Message, user : User) {
   access[r, user]
   r'.id = r.id
   r'.messages = r.messages + m
}

pred delMessage(r,r' : Room, m : Message, user : User) {
   access[r, user]
   r'.id = r.id
   r'.messages = r.messages - m
}

fun lsMesage(r : Room, user : User) : set Message {
  { message : Message | message in r.messages and access[r, user] }
}

// ------------------------------
// trace
// ------------------------------
pred opRoom(s, s' : System, room : Room, user : User) {
   addRoom[s, s', room, user] or delRoom[s, s', room, user]
}

pred opMember(r,r' : Room, member, user : User){
   addMember[r, r', member, user] or delMember[r,r',member, user]
}

pred opMessage(r, r' : Room, m : Message, u : User) {
   addMessage[r, r', m, u] or delMessage[r,r',m,u]
}

pred step(s, s' : System, user : User) {
   (some r : Room | opRoom[s,s',r, user]) or
   (some r : s.rooms, r' : s'.rooms, member : User | opMember[r,r', member, user] and s'.rooms = (s.rooms - r) + r')
   (some r : s.rooms, r' : s'.rooms, message : Message | opMessage[r,r', message, user] and s'.rooms = (s.rooms -r) + r')
}

pred init( s : System) { no s.rooms }
pred traces {
   init[first]
   all s : System - last | let s' = next [s] |
      some user : User | step[s,s', user]
}

assert invariant {
   all s,s' : System, u : User, before, after : set ID |
      before = lsRoom[s,u].id and
      after  = lsRoom[s',u].id and
      step[s,s',u] implies (after in before)
}

check invariant for 3
