sig Room {
 owener : User
}
sig User {}
sig Message {
 user : User, 
 belong : Room
}

sig Member {
 room : Room,
 user : User
}

fact {
 all disj a, b : Member | (no a.room & b.room) or (no a.user & b.user)
}

pred show () {}
run show for 5 but 
  exactly 2 Room,
  exactly 3 User,
  exactly 4 Message
