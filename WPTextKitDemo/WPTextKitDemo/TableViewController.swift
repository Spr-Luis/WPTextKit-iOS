import UIKit

class TableViewController : UITableViewController {
    let cellIdentifier = "CellIdentifier"

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "WPTextKit Examples"

        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.reloadData()
    }


    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }


    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)! as UITableViewCell

        var title:String
        if indexPath.row == 0 {
            title = "Sample HTML"

        } else if indexPath.row == 1 {
            title = "Simulated Async"

        } else {
            title = "Embedded Video"
        }

        cell.textLabel?.text = title
        cell.accessoryType = .DisclosureIndicator

        return cell
    }


    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        var controller:UIViewController

        if indexPath.row == 0 {
            controller = storyboard.instantiateViewControllerWithIdentifier("SampleViewController") as! SampleViewController

        } else if indexPath.row == 1 {
            controller = storyboard.instantiateViewControllerWithIdentifier("SampleAsyncViewController") as! SampleAsyncViewController

        } else {
            controller = storyboard.instantiateViewControllerWithIdentifier("SampleVideoViewController") as! SampleVideoViewController
        }

        navigationController?.pushViewController(controller, animated: true)
    }

}
