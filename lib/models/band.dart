
class Band {
  String id;
  String name;
  int votes;


  Band({
    this.id,
    this.name,
    this.votes
  });

  factory Band.fromMap( Map<String, dynamic> obj )
    => Band(
      id   : obj.containsKey('id')    ? obj['id'] : 'no-key',
      name : obj.containsKey('name')  ? obj['name'] : 'no-key',
      votes: obj.containsKey('votes') ? obj['votes'] : 'no-key'
    );
}