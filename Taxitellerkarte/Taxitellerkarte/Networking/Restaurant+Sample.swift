import Foundation

extension Restaurant {
    static let sampleBerlin = Restaurant(
        id: 1,
        slug: "manolo-9711",
        name: "Manolo Imbiss",
        cuisine: .greek,
        coordinate: .init(latitude: 52.5200, longitude: 13.4050),
        address: "Friedrichstraße 100",
        city: "Berlin",
        postcode: "10117",
        hasTaxiTeller: true,
        imageURL: nil,
        price: 7.50,
        paymentMethod: .both,
        note: "Klassiker am Bahnhof.",
        avgRating: 4.4,
        ratingCount: 27
    )

    static let sampleHamburg = Restaurant(
        id: 2,
        slug: "olympia-3210",
        name: "Olympia Grill",
        cuisine: .greek,
        coordinate: .init(latitude: 53.5511, longitude: 9.9937),
        address: "Reeperbahn 22",
        city: "Hamburg",
        postcode: "20359",
        hasTaxiTeller: true,
        imageURL: nil,
        price: 8.20,
        paymentMethod: .cash,
        note: nil,
        avgRating: 4.1,
        ratingCount: 14
    )

    static let sampleMunich = Restaurant(
        id: 3,
        slug: "akropolis-4823",
        name: "Akropolis Imbiss",
        cuisine: .greek,
        coordinate: .init(latitude: 48.1351, longitude: 11.5820),
        address: "Sendlinger Str. 1",
        city: "München",
        postcode: "80331",
        hasTaxiTeller: nil,
        imageURL: nil,
        price: nil,
        paymentMethod: nil,
        note: nil,
        avgRating: 0,
        ratingCount: 0
    )

    static let sampleCologne = Restaurant(
        id: 4,
        slug: "zorbas-1182",
        name: "Zorbas am Rhein",
        cuisine: .greek,
        coordinate: .init(latitude: 50.9375, longitude: 6.9603),
        address: "Hohe Str. 40",
        city: "Köln",
        postcode: "50667",
        hasTaxiTeller: false,
        imageURL: nil,
        price: nil,
        paymentMethod: nil,
        note: "Hat keinen Taxi Teller mehr im Angebot.",
        avgRating: 3.2,
        ratingCount: 6
    )

    static let sampleFrankfurt = Restaurant(
        id: 5,
        slug: "meraki-7755",
        name: "Meraki Imbiss",
        cuisine: .turkish,
        coordinate: .init(latitude: 50.1109, longitude: 8.6821),
        address: "Zeil 50",
        city: "Frankfurt",
        postcode: "60313",
        hasTaxiTeller: true,
        imageURL: nil,
        price: 9.90,
        paymentMethod: .card,
        note: nil,
        avgRating: 4.7,
        ratingCount: 42
    )

    static let sampleSet: [Restaurant] = [
        .sampleBerlin, .sampleHamburg, .sampleMunich, .sampleCologne, .sampleFrankfurt
    ]
}
