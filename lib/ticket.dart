class Ticket {
  String origin;
  String destination;
  double duration;
  String train;
  String coach;
  String date1;
  String date2;
  int pax;
  List<String> seats;
  double price;
  String userName;

  Ticket({
    required this.origin,
    required this.destination,
    required this.duration,
    required this.train,
    required this.coach,
    required this.date1,
    required this.date2,
    required this.pax,
    required this.seats,
    required this.price,
    required this.userName,
  });

  Map<String, dynamic> toMap() {
    return {
      'origin': origin,
      'destination': destination,
      'duration': duration,
      'train': train,
      'coach': coach,
      'date1': date1,
      'date2': date2,
      'pax': pax,
      'seats': seats,
      'price': price,
      'userName': userName,
    };
  }

  factory Ticket.fromMap(Map<String, dynamic> map) {
    return Ticket(
      origin: map['origin'] ?? '',
      destination: map['destination'] ?? '',
      duration: map['duration'] ?? '',
      train: map['train'] ?? '',
      coach: map['coach'] ?? '',
      date1: map['date1'] ?? '',
      date2: map['date2'] ?? '',
      pax: map['pax'] ?? '',
      seats: List<String>.from(map['seats'] ?? []),
      price: map['price'] ?? 0.0,
      userName: map['userName'] ?? '',
    );
  }

  factory Ticket.fromEmpty() {
    return Ticket(
      origin: '',
      destination: '',
      duration: 0.0,
      train: '',
      coach: '',
      date1: '',
      date2: '',
      pax: 0,
      seats: [],
      price: 0.0,
      userName: '',
    );
  }

  @override
  String toString() {
    return 'Ticket(origin: $origin, destination: $destination, duration: $duration, train: $train, coach: $coach, date1: $date1, date2: $date2, pax: $pax, seats: $seats, price: $price, userName: $userName)';
  }
}
