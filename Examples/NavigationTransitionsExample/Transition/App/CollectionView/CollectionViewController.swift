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
import AVFoundation


class CollectionViewController: UIViewController {
    
    static let margin: CGFloat = 10.0
    
    let items = Item.allItems()
    var selected: Item?
    var selectedImage: UIImageView?
    var header: CollectionViewCell?
    
    var targetFrame: CGRect = .zero
    
    lazy var collectionView: UICollectionView = {
        var layout = CollectionViewLayout()
        layout.delegate = self
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = nil
        collectionView.alwaysBounceVertical = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 10, right: 5)
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: CollectionViewCell.reuseIdentifier)
        return collectionView
    }()
    
    convenience init(with item: Item? = nil) {
        self.init()
        selected = item
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
        view.backgroundColor = UIColor(red: 82/255, green: 77/255, blue: 153/255, alpha: 1)
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        if let selected = selected {
            let margin = type(of: self).margin
            
            header = CollectionViewCell(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
            guard let header = header else { return }
            header.translatesAutoresizingMaskIntoConstraints = false
            header.item = selected
            header.container.backgroundColor = nil
            header.image.layer.cornerRadius = 6
            header.titleLabel.font = UIFont.systemFont(ofSize: 16)
            header.titleLabel.textColor = .white
            view.addSubview(header)
            
            let boundingRect = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - (2 * margin), height: CGFloat(MAXFLOAT))
            let height = AVMakeRect(aspectRatio: selected.image.size, insideRect: boundingRect).height
            
            var contentInset = collectionView.contentInset
            contentInset.top += height
            collectionView.contentInset = contentInset
            
            NSLayoutConstraint.activate([
                header.topAnchor.constraint(equalTo: view.topAnchor, constant: margin),
                header.leftAnchor.constraint(equalTo: view.leftAnchor, constant: margin),
                header.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -margin),
                header.heightAnchor.constraint(equalToConstant: height)
                ])
            
            header.layoutIfNeeded()
            view.layoutIfNeeded()
        }
        
        if let header = header {
            view.insertSubview(collectionView, belowSubview: header)
        } else {
            view.addSubview(collectionView)
        }
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor)
            ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    var hasFocus: Bool {
        return selected != nil
    }
}

extension CollectionViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCell.reuseIdentifier, for: indexPath)
    }
}

extension CollectionViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        header?.layer.transform = CATransform3DMakeTranslation(0, -scrollView.contentOffset.y - scrollView.contentInset.top, 0)
    }
}

extension CollectionViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let item = items[safe: indexPath.item] {
            
            if let cell = collectionView.cellForItem(at: indexPath) as? CollectionViewCell {
                targetFrame = view.convert(cell.image.frame, from: cell.image)
                selectedImage = cell.image
                
            }
            
            app?.router.go(to: .collection(item))
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if let cell = cell as? CollectionViewCell, let item = items[safe: indexPath.item] {
            cell.item = item
        }
    }
}

extension CollectionViewController : CollectionViewLayoutDelegate {
    
    func collectionView(_ collectionView:UICollectionView, heightForItemAtIndexPath indexPath: NSIndexPath, withWidth width: CGFloat) -> CGFloat {
        let item = items[indexPath.item]
        let boundingRect = CGRect(x: 0, y: 0, width: width, height: CGFloat(MAXFLOAT))
        let rect = AVMakeRect(aspectRatio: item.image.size, insideRect: boundingRect)
        
        return rect.height
    }
    
    func collectionView(_ collectionView: UICollectionView, heightForAnnotationAtIndexPath indexPath: NSIndexPath, withWidth width: CGFloat) -> CGFloat {
        
        let item = items[indexPath.item]
        let font = UIFont.systemFont(ofSize: 12)
        let height = item.heightForTitle(font, width: width)
        
        return height + 20
    }
}

extension Collection {
    
    subscript (safe index: Index) -> Iterator.Element? {
        return index >= startIndex && index < endIndex ? self[index] : nil
    }
}

extension CollectionViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if let navigationController = app?.router.navigationController {
            return navigationController.viewControllers.count > 1
        }
        
        return false
    }
}
