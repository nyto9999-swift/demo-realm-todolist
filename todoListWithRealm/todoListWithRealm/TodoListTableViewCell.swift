//
//  TodoListTableViewCell.swift
//  todoListWithRealm
//
//  Created by 宇宣 Chen on 2022/3/28.
//

import UIKit

class TodoListTableViewCell: UITableViewCell {
    
    let label:UILabel = {
        let label = UILabel()
        label.font = UIFont.monospacedSystemFont(ofSize: 22, weight: .semibold)
        label.textColor = .systemOrange
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        label.sizeToFit()
        return label
    }()
    
    lazy var subLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.monospacedSystemFont(ofSize: 14, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
         
        setupViews()
        setupConstraints()
    }
    
    func setupViews() {
        //dark mode check
        let color = contentView.traitCollection.userInterfaceStyle == .dark ? UIColor.white : UIColor.black
        subLabel.textColor = color
        
        contentView.addSubview(label)
        contentView.addSubview(subLabel)
    }
    
    func setupConstraints() {
        
        let viewsDict = [
            "label" : label,
            "subLabel" : subLabel
        ]
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[label]-[subLabel]-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(10)-[label]-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(10)-[subLabel]-|", options: [], metrics: nil, views: viewsDict))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10))
        contentView.backgroundColor = .systemGray5
        
    }
    
    func configure(task: Task){
        //
        //        let strokeEffect: [NSAttributedString.Key : Any] = [
        //            NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue,
        //            NSAttributedString.Key.strikethroughColor: UIColor .systemOrange,
        //        ]
        //
        label.text = task.desc
        subLabel.text = task.createdAt
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

