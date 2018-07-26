//
//  ViewController.swift
//  dragndrop
//
//  Created by Ada 2018 on 25/07/2018.
//  Copyright © 2018 Academy. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var dragTextView: UITextView!
    @IBOutlet weak var dropTextView: UITextView!
    
    @IBOutlet weak var dragImageView: UIImageView!
    @IBOutlet weak var dropImageView: UIImageView!
    
    var operation : UIDropOperation = .copy
    
    var range: UITextRange?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dropTextView.layer.borderWidth = 1
        dropTextView.layer.borderColor = UIColor.lightGray.cgColor
        
        dropImageView.layer.borderWidth = 1
        dropImageView.layer.borderColor = UIColor.lightGray.cgColor
        
        dragImageView.isUserInteractionEnabled = true
        dropImageView.isUserInteractionEnabled = true
        
        
        let dragImageInteraction = UIDragInteraction(delegate: self)
        
        dragImageView.addInteraction(dragImageInteraction)
        
        let dropImageInteraction = UIDropInteraction(delegate: self)
        
        dropImageView.addInteraction(dropImageInteraction)
        
        dragTextView.textDragDelegate = self
        
    }

}

extension ViewController: UIDragInteractionDelegate {
    
    
    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        
        if let textView = interaction.view as? UITextView {

            let textToDrag = textView.text

            let provider = NSItemProvider(object: textToDrag! as NSString)
            let item = UIDragItem(itemProvider: provider)
            return [item]
        }
        else if let imageView = interaction.view as? UIImageView {
            
            let imageToDrag = imageView.image
            
            let provider = NSItemProvider(object: imageToDrag!)
            let item = UIDragItem(itemProvider: provider)
            return [item]
        }

        return []
    }
    
    func dragInteraction(_ interaction: UIDragInteraction, itemsForAddingTo session: UIDragSession, withTouchAt point: CGPoint) -> [UIDragItem] {

        if let textView = interaction.view as? UITextView {
            let textToDrag = textView.text
            let provider = NSItemProvider(object: textToDrag! as NSString)
            let item = UIDragItem(itemProvider: provider)
            return [item]
        }
        else
            if let imageView = interaction.view as? UIImageView {
            guard let image = imageView.image else { return [] }
            let provider = NSItemProvider(object: image)
            let item = UIDragItem(itemProvider: provider)
            return [item]
        }
        return []
    }
    
}

extension ViewController: UITextDragDelegate {
    func textDraggableView(_ textDraggableView: UIView & UITextDraggable, dragPreviewForLiftingItem item: UIDragItem, session: UIDragSession) -> UITargetedDragPreview? {
        
        let dragView = textDraggableView
        
        let selectionRange = textDraggableView.selectedTextRange
        let selectionRects = textDraggableView.selectionRects(for: selectionRange!) as! [UITextSelectionRect]
        
        var array: [CGRect] = []
        
        for r in selectionRects {
            array.append(r.rect)
        }
        
        let paramaters = UIDragPreviewParameters(textLineRects: array as [NSValue])
        
        let textViewCopy = UITextView(frame: textDraggableView.frame)
    
        let attributedString = NSMutableAttributedString(attributedString: dragTextView.attributedText)
        
        let fullRange = attributedString.mutableString.range(of: dragTextView.text)
        let selectedRange = dragTextView.selectedRange
        attributedString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.white, range: fullRange)
        attributedString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.black, range: selectedRange)
        
        textViewCopy.attributedText = attributedString
        
        
        let target = UIDragPreviewTarget(container: self.view, center: dragTextView.center)
        
        let targeDragView = UITargetedDragPreview(view: textViewCopy, parameters: paramaters, target: target)
        
        return targeDragView
    }
    
    func textDraggableView(_ textDraggableView: UIView & UITextDraggable, itemsForDrag dragRequest: UITextDragRequest) -> [UIDragItem] {
        
        self.range = dragRequest.dragRange
        
        if let string = dragTextView.text(in: dragRequest.dragRange) {
            let itemProvider = NSItemProvider(object: string as NSString)
            return [UIDragItem(itemProvider: itemProvider)]
        }else{
            return []
        }
        
    }
}

extension ViewController: UIDropInteractionDelegate {
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        
        let location = session.location(in: self.view)
        
        let dropOperation: UIDropOperation?
        
        if session.canLoadObjects(ofClass: String.self) {
            if dropTextView.frame.contains(location) {
                dropOperation = .copy
            } else if  dropImageView.frame.contains(location) {
                dropOperation = .forbidden
            } else {
                dropOperation = .cancel
            }
        }
        else if session.canLoadObjects(ofClass: UIImage.self) {
            if dropImageView.frame.contains(location) {
                dropOperation = .copy
            } else if  dropTextView.frame.contains(location) {
                dropOperation = .forbidden
            } else {
                dropOperation = .cancel
            }
        }
        else {
            dropOperation = .cancel
        }
        
        return UIDropProposal(operation: dropOperation!)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        if session.canLoadObjects(ofClass: String.self) {
            session.loadObjects(ofClass: String.self) { (items) in
                let values = items as [String]
                self.dropTextView.text = values.last
            }
        } else if session.canLoadObjects(ofClass: UIImage.self) {
            session.loadObjects(ofClass: UIImage.self) { (items) in
                let images = items as! [UIImage]
                self.dropImageView.image = images.last
                images.map({ (image) -> UIImage in
                    print(image)
                    return image
                })
            }
        }
    }
}

