import Foundation

/// PostgreSQL's pg driver serializes BIGINT and NUMERIC as JSON strings
/// (to preserve precision), so the API returns e.g. `"osm_id": "251423841"`
/// and `"taxi_teller_price": "18.00"`. These helpers accept either form.
nonisolated extension KeyedDecodingContainer {
    func decodeFlexibleInt(forKey key: K) throws -> Int? {
        guard contains(key), try !decodeNil(forKey: key) else { return nil }
        if let v = try? decode(Int.self, forKey: key) { return v }
        if let s = try? decode(String.self, forKey: key) { return Int(s) }
        return nil
    }

    func decodeFlexibleInt64(forKey key: K) throws -> Int64? {
        guard contains(key), try !decodeNil(forKey: key) else { return nil }
        if let v = try? decode(Int64.self, forKey: key) { return v }
        if let s = try? decode(String.self, forKey: key) { return Int64(s) }
        return nil
    }

    func decodeFlexibleDouble(forKey key: K) throws -> Double? {
        guard contains(key), try !decodeNil(forKey: key) else { return nil }
        if let v = try? decode(Double.self, forKey: key) { return v }
        if let s = try? decode(String.self, forKey: key) { return Double(s) }
        return nil
    }

    func decodeFlexibleDecimal(forKey key: K) throws -> Decimal? {
        guard contains(key), try !decodeNil(forKey: key) else { return nil }
        if let v = try? decode(Decimal.self, forKey: key) { return v }
        if let s = try? decode(String.self, forKey: key) { return Decimal(string: s) }
        return nil
    }
}
