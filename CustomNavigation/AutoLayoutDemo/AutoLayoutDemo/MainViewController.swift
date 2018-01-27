//
//  MainViewController.swift
//  AutoLayoutDemo
//
//  Created by KuanWei on 2018/4/5.
//  Copyright © 2018年 Travostyle. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!

    let data = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.isTranslucent = false
        navigationController?.hidesBarsOnSwipe = true

        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        titleLabel.text = "  Home"
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont.systemFont(ofSize: 20)
        navigationItem.titleView = titleLabel

        setupNavBarButtons()
        setupMenuBar()


        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.contentInset = UIEdgeInsetsMake(50, 0, 0, 0)
        tableView.scrollIndicatorInsets = UIEdgeInsetsMake(50, 0, 0, 0)

//        vflExample()
    }

    func setupNavBarButtons() {
        let cancelImage = UIImage(named: "cancel")?.withRenderingMode(.alwaysOriginal)
        let cancelBarButtonItem = UIBarButtonItem(image: cancelImage, style: .plain, target: self, action: nil)
        cancelBarButtonItem.isEnabled = false
        navigationItem.leftBarButtonItem = cancelBarButtonItem

        let searchImage = UIImage(named: "search_icon")?.withRenderingMode(.alwaysOriginal)
        let searchBarButtonItem = UIBarButtonItem(image: searchImage, style: .plain, target: self, action: #selector(handleSearch))

        let moreButton = UIBarButtonItem(image: UIImage(named: "nav_more_icon")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleMore))

        navigationItem.rightBarButtonItems = [moreButton, searchBarButtonItem]
    }

    @objc func handleSearch() {
        print("handle search")
    }

    @objc func handleMore() {
        print("handle more")
    }

    lazy var menuBar: MenuBarView = {
        let mb = MenuBarView()
        return mb
    }()

    fileprivate func setupMenuBar() {

        let redView = UIView()
        redView.backgroundColor = UIColor.rgb(230, green: 32, blue: 31)
        view.addSubview(redView)

        view.addConstraintsWithFormat(format: "H:|[v0]|", views: redView)
        view.addConstraintsWithFormat(format: "V:[v0(50)]", views: redView)

        view.addSubview(menuBar)
        view.addConstraintsWithFormat(format: "H:|[v0]|", views: menuBar)
        view.addConstraintsWithFormat(format: "V:[v0(50)]", views: menuBar)

        menuBar.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
    }



    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    func vflExample() {
        let containerView1 = UIView()
        containerView1.backgroundColor = UIColor.black
        containerView1.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(containerView1)

//        let descHorizontal = "H:[containerView1(200)]"
//        let descVertical = "V:[containerView1(150)]"

        let descHorizontal = "H:|-[containerView1(200)]"
        let descVertical = "V:|-100-[containerView1(150)]"


        let viewsDict = ["containerView1": containerView1]

        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: descHorizontal,
                                                                   options: NSLayoutFormatOptions(rawValue: 0),
                                                                   metrics: nil,
                                                                   views: viewsDict)

        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: descVertical,
                                                                 options: NSLayoutFormatOptions(rawValue: 0),
                                                                 metrics: nil,
                                                                 views: viewsDict)

        self.view.addConstraints(horizontalConstraints)
        self.view.addConstraints(verticalConstraints)

    }

    func complexView1() {
        let containerView1 = UIView()
        containerView1.backgroundColor = UIColor.black
        self.view.addSubview(containerView1)
        containerView1.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint(item: containerView1, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: containerView1, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 80.0).isActive = true
        NSLayoutConstraint(item: containerView1, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 150.0).isActive = true
        NSLayoutConstraint(item: containerView1, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 100.0).isActive = true

        let button1 = UIButton(type: .custom)
        button1.backgroundColor = UIColor.orange
        button1.setTitle("@1x", for: .normal)
        button1.setTitleColor(.white, for: .normal)
        button1.translatesAutoresizingMaskIntoConstraints = false
        containerView1.addSubview(button1)

        let centerHorizontally = NSLayoutConstraint(item: button1, attribute: .centerX, relatedBy: .equal, toItem: containerView1, attribute: .centerX, multiplier: 1.0, constant: 0.0)
    }


    func simpleView1() {
        let myView = UIView()
        myView.backgroundColor = UIColor.black

        self.view.addSubview(myView)

        let leading = NSLayoutConstraint(item: myView,
                                         attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 50)
        let trailing = NSLayoutConstraint(item: myView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: -50)

        let top = NSLayoutConstraint(item: myView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 100)
        let height = NSLayoutConstraint(item: myView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 120)

//        view.addConstraint(leading)
        view.addConstraints([leading, trailing, top, height])

        myView.translatesAutoresizingMaskIntoConstraints = false
    }

}
