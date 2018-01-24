//
//    MIT License
//
//    Copyright (c) 2017 Touchwonders B.V.
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to deal
//    in the Software without restriction, including without limitation the rights
//    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//    copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in all
//    copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//    SOFTWARE.


import UIKit


class Item {
    
    class func allItems() -> [Item] {
        var items = [Item]()
        if let URL = Bundle.main.url(forResource: "Items", withExtension: "plist") {
            if let itemsFromPlist = NSArray(contentsOf: URL) {
                for dictionary in itemsFromPlist {
                    let item = Item(dictionary: dictionary as! NSDictionary)
                    items.append(item)
                }
            }
        }
        return items
    }
    
    var title: String
    var image: UIImage
    
    init(title: String, image: UIImage) {
        self.title = title
        self.image = image
    }
    
    convenience init(dictionary: NSDictionary) {
        let title = dictionary["Title"] as? String
        
        
        let image: UIImage?
        if let photo = dictionary["Photo"] as? String {
            image = UIImage.random(i: Int(photo)!)
        } else {
            image = UIImage.random(i: 0)
        }
    
        self.init(title: title ?? "", image: image!)
    }
    
    func heightForTitle(_ font: UIFont, width: CGFloat) -> CGFloat {
        let rect = NSString(string: title).boundingRect(with: CGSize(width: width, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
        return ceil(rect.height)
    }
    
    static func == (lhs: Item, rhs: Item) -> Bool {
        switch (lhs, rhs) {
        case (let leftItem, let rightItem): return leftItem.image == rightItem.image
        }
    }
}

extension Item : Equatable {}


extension UIImage {
    
    static func random(i: Int) -> UIImage? {
        
        let index = i % 4
        
        let height: CGFloat = 150 + CGFloat(arc4random_uniform(250))
        
        let rect = CGRect(x: 0, y: 0, width: 300, height: height)
        UIGraphicsBeginImageContext(rect.size)
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        context.setFillColor(color(index).withAlphaComponent(0.9).cgColor)
        context.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
