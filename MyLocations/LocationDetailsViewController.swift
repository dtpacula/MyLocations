import UIKit
import CoreLocation

private let dateFormatter: NSDateFormatter = {
    
    let formatter = NSDateFormatter()
    formatter.dateStyle = .MediumStyle
    formatter.timeStyle = .ShortStyle
    return formatter
}()

func formatDate(date: NSDate) -> String {
    
    return dateFormatter.stringFromDate(date)
}

class LocationDetailsViewController: UITableViewController {
    
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var placemark: CLPlacemark?
    
    @IBAction func done() {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancel() {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        descriptionTextView.text = ""
        categoryLabel.text = ""
        
        latitudeLabel.text = String(format: "%.8f", coordinate.latitude)
        longitudeLabel.text = String(format: "%.8f", coordinate.longitude)
        
        if let placemark = placemark
        {
            addressLabel.text = stringFromPlacemark(placemark)
        }
        else
        {
            addressLabel.text = "No Adress Found"
        }
        
        dateLabel.text = formatDate(NSDate())
    }
    
    func stringFromPlacemark(placemark: CLPlacemark) -> String {
        
        var text = ""
        
        if let s = placemark.subThoroughfare
        {
            text += s + " "
        }
        
        if let s = placemark.thoroughfare
        {
            text += s + ", "
        }
        
        if let s = placemark.locality
        {
            text += s + ", "
        }
        
        if let s = placemark.administrativeArea {
            
            text += s + " "
        }
        
        if let s = placemark.postalCode
        {
            text += s + ", "
        }
        
        if let s = placemark.country
        {
            text += s
        }
        
        return text
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.section == 0 && indexPath.row == 0
        {
            return 88
        }
        else if indexPath.section == 2 && indexPath.row == 2
        {
            addressLabel.frame.size = CGSize(width: view.bounds.size.width - 115, height: 10000)
            addressLabel.sizeToFit()
            addressLabel.frame.origin.x = view.bounds.size.width - addressLabel.frame.size.width - 15
            
            return addressLabel.frame.size.height + 20
        }
        else
        {
            return 44
        }
    }
}