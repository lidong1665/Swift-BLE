//
//  HexUtil.swift
//  Swift-BLE
//
//  Created by lidong on 16/7/4.
//  Copyright © 2016年 李东. All rights reserved.
//

import Foundation

class HexUtil{
    
    enum HexError : Error {
        case oddLength
        case invalidByte
    }
    
    
    static func encodeToString(_ hexBytes: [UInt8]) -> String {
        var outString = ""
        for val in hexBytes {
            // Prefix with 0 for values less than 16.
            if val < 16 { outString += "0" }
            outString += String(val, radix: 16)
        }
        return outString
    }
    
    static func trimString(_ theString: String) -> String? {
        let trimmedString = theString.trimmingCharacters(in: CharacterSet(charactersIn: "<> ")).replacingOccurrences(of: " ", with: "")
        
        // Clean up string to remove non-hex digits.
        // Ensure there is an even number of digits.
        do {
            
            let regex = try NSRegularExpression(pattern: "^[0-9a-f]*$", options: .caseInsensitive)
            let found = regex.firstMatch(in: trimmedString, options: [], range: NSMakeRange(0, trimmedString.characters.count))
            
            if found == nil || found?.range.location == NSNotFound || trimmedString.characters.count % 2 != 0 {
                return nil
            }
            
            return trimmedString
            
        } catch {
            print("Regular expression failed \(error)")
            return nil
        }
    }
    
   static func decode(_ source: [UInt8]) throws -> [UInt8] {
        
        let srcLength = source.count
        var decoded: [UInt8] = []
        // Make sure we have an even length.
        if srcLength % 2 == 1 { throw HexError.oddLength }
        
        for i in 0..<srcLength/2 {
            guard let hexVal1 = fromHexChar(source[i<<1]) else { throw HexError.invalidByte }
            
            guard let hexVal2 = fromHexChar(source[(i<<1)+1]) else { throw HexError.invalidByte }
            
            decoded.append(hexVal1 << 4 | hexVal2)
        }
        
        return decoded
    }
    
   static func fromHexChar(_ hexChar: UInt8) -> UInt8? {
        
        switch UnicodeScalar(hexChar) {
        case let c where c >= UnicodeScalar("0") && c <= UnicodeScalar("9") :
            return UInt8(c.value - UnicodeScalar("0").value)
            
        case let c where c >= UnicodeScalar("a") && c <= UnicodeScalar("f") :
            return UInt8(c.value - UnicodeScalar("a").value ) + 10
            
        case let c where c >= UnicodeScalar("A") && c <= UnicodeScalar("F") :
            return UInt8(c.value - UnicodeScalar("A").value ) + 10            
        default:
            return nil
        }
    }
    
    /** Takes a hexadecimal number as a string and converts it into bytes.*/
    internal static func decodeString(_ hexString: String) throws -> [UInt8] {
        let src = [UInt8](hexString.utf8)
        let dest = try decode(src)
        return dest
    }
    
}
