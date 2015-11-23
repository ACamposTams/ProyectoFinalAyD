pdf.text "#{current_user.first_name(&:capitalize)} #{current_user.last_name(&:capitalize)} Event Statistics", :size => 30, :font => "Times New Roman"

pdf.move_down(30)

@events.each do |e|
pdf.text "Event:" " #{e.name}"
pdf.text "Date and time: " " #{e.datetime}"
@sumInvites = EventsUser.where("event_id = ? AND owner != ?", e.id, current_user.id).count
pdf.text "Total invites: " " #{@sumInvites}"
@sumGoing =  EventsUser.where("event_id = ? AND owner != ? AND status = ?", e.id, current_user.id, 'going').count
pdf.text "Total going: " " #{@sumGoing}"
end
pdf.move_down(10)