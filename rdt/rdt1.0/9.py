# -*- coding: utf-8 -*-
"""
Created on Tue May  7 18:40:18 2019

@author: Administrator
"""


import java.applet.Applet;
import java.awt;
import java.awt.event.ActionListener;
import java.awt.event.ActionEvent;

public class GBN extends Applet implements ActionListener, Runnable {
   
   private static final int ADVANCE_PACKET = 5;
   
   final int sender_window_len_def = 5;
   
   final int receiver_window_len = 1;
   
   final int pack_width_def = 10;
   final int pack_height_def = 30;
   final int h_offset_def = 100;
   final int v_offset_def = 50;
   final int v_clearance_def = 300;

   
   final int TIMEOUT_MULTIPLIER = 1000;

   final int MIN_FPS = 3;
   final int FPS_STEP = 2;
   final int DESELECTED = -1;
   final int DEFAULT_FPS = 5;
   
   final int total_packet_def = 20;
   
   final int time_out_sec_def = 25;
   
   
   final Color unack_color = new Color(204, 230, 247);
   final Color ack_color = Color.yellow;
   final Color sel_color = Color.green;
   final Color roam_pack_color = new Color(204, 230, 247);
   final Color roam_ack_color = Color.yellow;
   final Color dest_color = Color.red;
   final Color received_ack = new Color(37, 135, 234);
   
  
   int base, receiver_base, nextseq, fps, selected = DESELECTED, timeout,
      timeoutPacket, lastKnownSucPacket;
   boolean timerFlag, timerSleep;
   
   
   Button send, stop, fast, slow, kill, reset;
   
   Thread gbnThread, timerThread;
   
   TextArea output;
   Dimension offDimension;
   Image offImage;
   Graphics offGraphics; 
   GoBackNPacket sender[]; 
   int window_len, pack_width, pack_height, h_offset, v_offset, v_clearance,
      total_packet, time_out_sec;
   
   
   
   
   public void init() {
      
      
      setLayout(null);
      output = new TextArea(150, 150); 
      output.setBounds(0, 400, 650, 250); 
      output.setEditable(false);
      
      add(output);
      
      setupSimulationParams();
      
      base = 0;
      receiver_base = 0; 
      nextseq = 0; 
      fps = DEFAULT_FPS; 

      
     
      sender = new GoBackNPacket[total_packet];
      
      
      send = new Button("Send New");
      
      send.setActionCommand("rdt");
     
      send.addActionListener(this);
     
      send.setBounds(0, 0, 90, 20);
      
      
      stop = new Button("Pause");
      stop.setActionCommand("stopanim");
      stop.addActionListener(this);
      stop.setBounds(90, 0, 90, 20);
      
      fast = new Button("Faster");
      fast.setActionCommand("fast");
      fast.addActionListener(this);
      fast.setBounds(180, 0, 90, 20);
   
      slow = new Button("Slower");
      slow.setActionCommand("slow");
      slow.addActionListener(this);
      slow.setBounds(270, 0, 90, 20);
      
      kill = new Button("Kill Packet/Ack");
      kill.setActionCommand("kl");
      kill.addActionListener(this);
      kill.setEnabled(false);
      kill.setBounds(360, 0, 90, 20);
      
      reset = new Button("Reset");
      reset.setActionCommand("rst");
      reset.addActionListener(this);
      reset.setBounds(450, 0, 90, 20);
      
     
      add(send);
      add(stop);
      add(fast);
      add(slow);
      add(kill);
      add(reset);
      
      
      output.append("- GoBackN Applet written by Matt Shatley & Chris Hoffman\n");
      output.append("- Advised by Professor Paul D. Amer (amer@udel.edu), U of Delaware, 2008\n");
      output.append("- Updated by Chris Hoffman and Professor Amer, 2012\n\n");
      
      
      output.append("-Ready to run. Press 'Send New' button to start.\n");
      
   }
   public void start() {
      
      if (gbnThread == null)
	 gbnThread = new Thread(this);
      gbnThread.start();
   }
   
   
   public void run() {
      
      if (sender[total_packet - 1] != null)
	 if (sender[total_packet - 1].acknowledged) {
	    sender[total_packet - 1].packet_pos += ADVANCE_PACKET;
	    gbnThread = null;
	    output.append("Data Transferred - Simulation completed\n");
	    return;
	 }
      
      System.gc();
     Thread currenthread = Thread.currentThread();
      
      
      while (currenthread == gbnThread) {
	 
	 if (onTheWay(sender)) {
	    for (int i = 0; i < total_packet; i++)
	       if (sender[i] != null)
		  if (sender[i].on_way) 
			    
		     if (sender[i].packet_pos < (v_clearance - pack_height))
			sender[i].packet_pos += ADVANCE_PACKET;

	    
	    
		     else if (sender[i].packet_ack) {
			deliverPackets(i);
		     } else if (!sender[i].packet_ack) {
			
			if (sender[i].ackFor != i) {
			   
			   int location = sender[i].ackFor;
			   
			   if (!sender[location].acknowledged) {
			      
			      output.append("(S) - Cumulative Ack received for Packet(s) up to and including Packet " + location + ". Timer for Packet(s) up to and including " + location + " stopped\n");
			      sender[location].received = true;
			      sender[location].on_way = false;
			      sender[location].acknowledged = true;
			      sender[i].packet_ack = false;
			      sender[i].on_way = false;
			      
			      
			      simGoBackN(location);
			      
			   } else {
			     
			      output.append("(S) - Cumulative Ack for Packet(s) up to and including " + sender[i].ackFor + " received again (DUPACK)\n");
			      sender[i].packet_pos = pack_height + ADVANCE_PACKET;
			      sender[i].packet_ack = false;
			      sender[i].on_way = false;
			   }
			} else {
			   
			   output.append("(S) - Cumulative Ack received for Packet(s) up to and including  " + i  + "\n");
			   output.append("(S) - Stop timer\n");
			   
			   
			   if(i < total_packet_def && sender[i + 1] != null)
			   {
				   output.append("(S) - Start timer (for Packet " + (i+1) + ")\n");
			   }
			   
			   sender[i].received = true;
			   sender[i].on_way = false;
			   
			   
			   simGoBackN(i);
			}
		     }
	    
	    repaint();
	    
	    try {
	       Thread.sleep(TIMEOUT_MULTIPLIER / fps);
	       timeout = (TIMEOUT_MULTIPLIER / fps);
	      
	    } catch (InterruptedException e) {
	       output.append("-Help\n");
	    }
	 }
	 else
	    gbnThread = null;
      }
      
      while (currenthread == timerThread) {
	 
	 if (timerSleep) {
	    timerSleep = false;
	    try {
	       Thread.sleep(time_out_sec * TIMEOUT_MULTIPLIER);
	       timeout = (time_out_sec * TIMEOUT_MULTIPLIER);
	    } catch (InterruptedException e) {
	       output.append("-Timer interrupted.\n");
	       return;
	    }
	 } else
	    retransmitOutstandingPackets();
      }
   }
   
   
   private void retransmitOutstandingPackets() {
      
      for (int n = (base == 0) ? 0 : base - 1; n < base + window_len; n++) {
	 if (sender[n] != null)
	    if (!sender[n].acknowledged) {
	       sender[n].on_way = true;
	       sender[n].packet_ack = true;
	       sender[n].packet_pos = pack_height + ADVANCE_PACKET;
	       sender[n].ackFor = n;
	    }
	 timerSleep = true;
	 
	 if (gbnThread == null) {
         gbnThread = new Thread(this);
         gbnThread.start();
	 }
	 
      }
      for(int i = base; i < total_packet; i++)
    	  if(sender[i].acknowledged == false)
    	  {
      		  output.append("(S) - Timeout occurred (for Packet " + (i) + ") \n");
    		  break;
    	  }
      output.append("(S) - All outstanding Packet(s) from " + base + " to " + (nextseq - 1) + " are retransmitted. Start timer (for Packet "+ base +")\n");
   }
   
   
   public void simGoBackN(int i) {
      
      for (int n = 0; n <= i; n++) {
	 sender[n].acknowledged = true;
      }
      
      if (i == selected) {
	 selected = DESELECTED;
	 kill.setEnabled(false);
      }
      
      timerThread = null; // resetting timer thread
      
      if (i + window_len < total_packet)
	 base = i + 1;
      
     
      if (nextseq < base + window_len)
	 send.setEnabled(true);
      
      if (base != nextseq) {
	 timerThread = new Thread(this);
	 timerSleep = true;
	 timerThread.start();
      } else
	
	 sender[i].out_of_order = false;
   }
   
   
   private void deliverPackets(int packetNumber) {
      sender[packetNumber].reached_dest = true;
      
      
      if (sender[packetNumber].ackFor != packetNumber) {
	 output.append("(S) Cumulative Ack for Packets up to and including " + sender[packetNumber].ackFor + " received again (DUPACK)\n");
	 sender[packetNumber].packet_pos = pack_height + ADVANCE_PACKET;
	 sender[packetNumber].packet_ack = false;
	 
      } else if (check_upto_n(packetNumber) && packetNumber >= receiver_base) {
	 sender[packetNumber].packet_pos = pack_height + ADVANCE_PACKET;
	 sender[packetNumber].packet_ack = false;
	 lastKnownSucPacket = packetNumber;
	 output.append("(R) - Packet " + packetNumber + " received. Cumulative Ack for Packets up to and including " + packetNumber  + " sent. Packet " + packetNumber + " delivered to application\n");
	 
	 if (receiver_base + 1 < total_packet && receiver_base <= lastKnownSucPacket)
	    receiver_base = receiver_base + 1;
      }
      
      
      else {
	 
	 if (base == 0 && sender[0].packet_ack && receiver_base ==0) {
	    output.append("(R) - Packet " + packetNumber + " received out of order - no Packets acknowledged. Special case -  No Ack sent\n");
	    sender[packetNumber].packet_pos = pack_height + ADVANCE_PACKET;
	    sender[packetNumber].on_way = false;
	    sender[packetNumber].reached_dest = false;

	 }
	 
	 else if(packetNumber < receiver_base){
	    sender[packetNumber].packet_pos = pack_height + ADVANCE_PACKET;
	    sender[packetNumber].packet_ack = false;
	    
	    output.append("(R) - Packet " + packetNumber + " received out of order Dropping Packet " + packetNumber + ". Cumulative Ack for Packets up to and including " + (lastKnownSucPacket) + " sent\n");
	 }
	 
	 else {
	    sender[packetNumber].packet_pos = pack_height + ADVANCE_PACKET;
	    sender[packetNumber].packet_ack = false;
	    
	    sender[packetNumber].ackFor = lastKnownSucPacket;
	    sender[packetNumber].reached_dest = false;
	    sender[packetNumber].out_of_order = true;
	    
	    output.append("(R) - Packet " + packetNumber + " received out of order. Dropping Packet " + packetNumber + ". Cumulative Ack for Packets up to and including " + (lastKnownSucPacket) + " sent\n");
	    if (packetNumber == selected) {
	       selected = DESELECTED;
	       kill.setEnabled(false);
	    }
	 }
      }
   }

   private void setupSimulationParams() {
      
      String strWinLen, strPackWd, strPackHt, strHrOff, strVtOff, strVtClr, strTotPack, strTimeout;

      strWinLen = getParameter("window_length");
      strPackWd = getParameter("packet_width");
      strPackHt = getParameter("packet_height");
      strHrOff = getParameter("horizontal_offset");
      strVtOff = getParameter("vertical_offset");
      strVtClr = getParameter("vertical_clearance");
      strTotPack = getParameter("total_packets");
      strTimeout = getParameter("timer_time_out");

      try {

	 if (strWinLen != null) {
	    
	    window_len = Integer.parseInt(strWinLen);
	    window_len = (window_len > 0) ? window_len : sender_window_len_def;
	 } else
	    
	    window_len = sender_window_len_def;

	 
	 if (strPackWd != null) {
	    pack_width = Integer.parseInt(strPackWd);
	    pack_width = (pack_width > 0) ? pack_width : pack_width_def;
	 } else
	    pack_width = pack_width_def;

	 if (strPackHt != null) {
	    pack_height = Integer.parseInt(strPackHt);
	    pack_height = (pack_height > 0) ? pack_height : pack_height_def;
	 } else
	    pack_height = pack_height_def;

	 if (strHrOff != null) {
	    h_offset = Integer.parseInt(strHrOff);
	    h_offset = (h_offset > 0) ? h_offset : h_offset_def;
	 } else
	    h_offset = h_offset_def;

	 if (strVtOff != null) {
	    v_offset = Integer.parseInt(strVtOff);
	    v_offset = (v_offset > 0) ? v_offset : v_offset_def;
	 } else
	    v_offset = v_offset_def;

	 if (strVtClr != null) {
	    v_clearance = Integer.parseInt(strVtClr);
	    v_clearance = (v_clearance > 0) ? v_clearance : v_clearance_def;
	 } else
	    v_clearance = v_clearance_def;

	 if (strTotPack != null) {
	    total_packet = Integer.parseInt(strTotPack);
	    total_packet = (total_packet > 0) ? total_packet
	       : total_packet_def;
	 } else
	    total_packet = total_packet_def;

	 if (strTimeout != null) {
	    time_out_sec = Integer.parseInt(strTimeout);
	    time_out_sec = (time_out_sec > 0) ? time_out_sec
	       : time_out_sec_def;
	 } else
	    time_out_sec = (time_out_sec > 0) ? time_out_sec
	       : time_out_sec_def;
	 
	  } catch (Exception e) {
	 
	 window_len = (window_len > 0) ? window_len : sender_window_len_def;
	 pack_width = (pack_width > 0) ? pack_width : pack_width_def;
	 pack_height = (pack_height > 0) ? pack_height : pack_height_def;
	 h_offset = (h_offset > 0) ? h_offset : h_offset_def;
	 v_offset = (v_offset > 0) ? v_offset : v_offset_def;
	 v_clearance = (v_clearance > 0) ? v_clearance : v_clearance_def;
	 total_packet = (total_packet > 0) ? total_packet : total_packet_def;
	 time_out_sec = (time_out_sec > 0) ? time_out_sec : time_out_sec_def;
      }
      
   }

   public void actionPerformed(ActionEvent e) {

      String cmd = e.getActionCommand();
      
      
      if (cmd == "rdt" && nextseq < base + window_len) {
	 
	 sender[nextseq] = new GoBackNPacket(true, pack_height + ADVANCE_PACKET, nextseq);
	 
	 output.append("(S) - Packet " + nextseq + " sent\n");
	 if(timerThread == null)
		 output.append("(S) - Start timer (for Packet " + nextseq + ")\n");
	 else
		 output.append("(S) - Timer already running\n");
	 if (base == nextseq) // i.e. the window is empty and new data is
	    
	    {
	       
	       if (timerThread == null)
		  timerThread = new Thread(this);
	       timerSleep = true;
	       timerThread.start();
	    }
	 
	 repaint();
	 nextseq++;
	 if (nextseq == base + window_len)
	    send.setEnabled(false);
	 start();
      }
     
      else if (cmd == "fast") // Faster button pressed
	 {
	    fps += FPS_STEP;
	    output.append("-Simulation speed increased\n");
	 }
     
      else if (cmd == "slow" && fps > MIN_FPS) {
	 fps -= FPS_STEP;
	 output.append("-Simulation speed decreased\n");
      }
     
      else if (cmd == "stopanim") {
	 output.append("- Simulation paused\n");
	 gbnThread = null;
	 
	 if (timerThread != null) {
	    timerFlag = true;
	    timerThread = null; // added later
	 }
	 
	 stop.setLabel("Resume");
	 stop.setActionCommand("startanim");
	
	 send.setEnabled(false);
	 slow.setEnabled(false);
	 fast.setEnabled(false);
	 kill.setEnabled(false);
	 
	 repaint();
      }
      
      
      else if (cmd == "startanim") {
	 output.append("-Simulation resumed.\n");
	 stop.setLabel("Pause");
	 stop.setActionCommand("stopanim");
	 
	 if (timerFlag) {
	    timerThread = new Thread(this);
	    timerSleep = true;
	    timerThread.start();
	 }
	 
	 send.setEnabled(true);
	 slow.setEnabled(true);
	 fast.setEnabled(true);
	 kill.setEnabled(true);

	 repaint(); 
	 start();
	 
      }
    
      else if (cmd == "kl") {
	 if (sender[selected].packet_ack) {
	    output.append("-Packet " + selected + " lost\n");
	 } else
	    output.append("-Cumulative Ack of Packet " + selected + " lost.\n");
	 
	 sender[selected].on_way = false;
	 kill.setEnabled(false);
	 selected = DESELECTED;
	 repaint();
      }
     
      else if (cmd == "rst")
	 reset_app();
   }

    public boolean mouseDown(Event e, int x, int y) {
	int location, xpos, ypos;
	location = (x - h_offset) / (pack_width + 7);
	
	if (location >= total_packet || location < 0){
	    selected = DESELECTED;
	    return false;
	}
	if (sender[location] != null) {
	    xpos = h_offset + (pack_width + 7) * location;
	    ypos = sender[location].packet_pos;
	    
	    if (x >= xpos && x <= xpos + pack_width && sender[location].on_way) {
	    	if ((sender[location].packet_ack && y >= v_offset + ypos && y <= v_offset + ypos + pack_height) || 
		       ((!sender[location].packet_ack) && y >= v_offset + v_clearance - ypos && y <= v_offset + v_clearance - ypos + pack_height)) {
		    if (sender[location].packet_ack)
			output.append("-Packet " + location + " selected.\n");
		    else
			output.append("-Cumulative Ack " + location + " selected.\n");
		
		    sender[location].selected = true;
		    selected = location;
		    kill.setEnabled(true);
		    repaint();
		    
		} else {
		    output.append("-Click on a moving Packet to select.\n");
		    selected = DESELECTED;
		}
	    } else {
		output.append("-Click on a moving Packet to select.\n");
		selected = DESELECTED;
	    }
      }
      
      return true;
   }

   public void paint(Graphics g) {
      update(g);
   }
   public void update(Graphics g) {
      Dimension d = size();
     
      if ((offGraphics == null) || (d.width != offDimension.width)
	  || (d.height != offDimension.height)) {
	 offDimension = d;
	 offImage = createImage(d.width, d.height);
	 offGraphics = offImage.getGraphics();
      }
     
      offGraphics.setColor(Color.white);
      offGraphics.fillRect(0, 0, d.width, d.height);
     
      offGraphics.setColor(Color.black);
      
      offGraphics.draw3DRect(h_offset + base * (pack_width + 7) - 4, v_offset - 3, (window_len) * (pack_width + 7) + 1, pack_height + 6, true);
      
      offGraphics.draw3DRect(h_offset + receiver_base * (pack_width + 7) - 4,v_offset + 222, ((receiver_window_len) * (pack_width + 7) + 1),pack_height + 6, true);
      
      for (int i = 0; i < total_packet; i++) {
	 
	 offGraphics.setColor(Color.black);
	 offGraphics.drawString("" + i, h_offset + (pack_width + 7) * i, v_offset - 4);
	 offGraphics.drawString("" + i, h_offset + (pack_width + 7) * i, v_offset + v_clearance + 30);
	
	 if (sender[i] == null) {
	    offGraphics.setColor(Color.black);
	    offGraphics.draw3DRect(h_offset + (pack_width + 7) * i,v_offset, pack_width, pack_height, true);
	    offGraphics.draw3DRect(h_offset + (pack_width + 7) * i,v_offset + v_clearance, pack_width, pack_height, true);
	 } else {
	   
	    if (sender[i].acknowledged)
	       offGraphics.setColor(received_ack);
	    else
	       offGraphics.setColor(unack_color);
	    
	    offGraphics.fill3DRect(h_offset + (pack_width + 7) * i,v_offset, pack_width, pack_height, true);
	    if (sender[i].buffered)
	       offGraphics.setColor(Color.GRAY);
	    else
	       
	       offGraphics.setColor(dest_color);
	    
	    if (sender[i].reached_dest)
	       offGraphics.fill3DRect(h_offset + (pack_width + 7) * i,v_offset + v_clearance, pack_width, pack_height, true);
	    
	    else {
	       offGraphics.setColor(Color.black);
	       offGraphics.draw3DRect(h_offset + (pack_width + 7) * i, v_offset + v_clearance, pack_width, pack_height, true);
	    }
	   
	    if (sender[i].on_way) {
	       if (i == selected)
		  offGraphics.setColor(sel_color);
	       
	       else if (sender[i].packet_ack)
		  offGraphics.setColor(roam_pack_color);
	       else if (sender[i].received)
		  offGraphics.setColor(received_ack);
	       else
		  offGraphics.setColor(roam_ack_color);
	       
	       if (sender[i].packet_ack) {
		  offGraphics.fill3DRect(h_offset + (pack_width + 7) * i,v_offset + sender[i].packet_pos, pack_width,pack_height, true);
		  offGraphics.setColor(Color.black);
		  offGraphics.drawString("" + i, h_offset+ (pack_width + 7) * i, v_offset+ sender[i].packet_pos);
	       } else {
		  
		  offGraphics.fill3DRect(h_offset + (pack_width + 7) * i,v_offset + v_clearance - sender[i].packet_pos,pack_width, pack_height, true);
		  if (sender[i].out_of_order) {
		     offGraphics.setColor(Color.black);
		     offGraphics.drawString("" + sender[i].ackFor,h_offset + (pack_width + 7) * i, v_offset+ v_clearance - sender[i].packet_pos);
		  } else {
		     offGraphics.setColor(Color.black);
		     offGraphics.drawString("" + i, h_offset + (pack_width + 7) * i, v_offset + v_clearance - sender[i].packet_pos);
		  }
	       }
	    } 
	 } 
      } 
     
      offGraphics.setColor(Color.black);
      int newvOffset = v_offset + v_clearance + pack_height;
      int newHOffset = h_offset;
      
      offGraphics.drawString("(S) - Action at Sender                  (R) - Action at Receiver",newHOffset + 60, newvOffset + 90);
      
      offGraphics.drawString("Packet", newHOffset + 15, newvOffset + 60);
      offGraphics.drawString("Ack Received", newHOffset + 225,newvOffset + 60);
      offGraphics.drawString("Ack", newHOffset + 170, newvOffset + 60);
      offGraphics.drawString("Received", newHOffset + 85, newvOffset + 60);
      offGraphics.drawString("Selected", newHOffset + 335, newvOffset + 60);
      
      offGraphics.drawString("base = " + base, h_offset + (pack_width + 7)* total_packet + 10, v_offset + 33);
      offGraphics.drawString("nextseqnum = " + nextseq, h_offset + (pack_width + 7) * total_packet + 10, v_offset + 50);
      
      offGraphics.setColor(Color.blue);
      offGraphics.drawString("Sender (Send Window Size = " + window_len + ")", h_offset + (pack_width + 7) * total_packet + 10, v_offset + 12);
      offGraphics.drawString("Receiver (Receiver Window Size = " +  receiver_window_len + ")", h_offset + (pack_width + 7) * total_packet + 10, v_offset + v_clearance + 12);
      offGraphics.setColor(Color.gray);
      offGraphics.draw3DRect(newHOffset - 10, newvOffset + 42, 400, 25, true);
      offGraphics.setColor(roam_pack_color);
      offGraphics.fill3DRect(newHOffset, newvOffset + 50, 10, 10, true);
      offGraphics.setColor(roam_ack_color);
      offGraphics.fill3DRect(newHOffset + 155, newvOffset + 50, 10, 10, true);
      offGraphics.setColor(received_ack);
      offGraphics.fill3DRect(newHOffset + 210, newvOffset + 50, 10, 10, true);
      offGraphics.setColor(dest_color);
      offGraphics.fill3DRect(newHOffset + 70, newvOffset + 50, 10, 10, true);
      offGraphics.setColor(sel_color);
      offGraphics.fill3DRect(newHOffset + 320, newvOffset + 50, 10, 10, true);
      
      g.drawImage(offImage, 0, 0, this);
   } 
   public boolean onTheWay(GoBackNPacket pac[]) {
      
      for (int i = 0; i < pac.length; i++)
	 if (pac[i] == null)
	    return false;
	 else if (pac[i].on_way)
	    return true;
      
      return false;
   }
  
   public boolean check_upto_n(int packno) {
      for (int i = 0; i < packno; i++)
	 if (!sender[i].reached_dest)
	    return false;
      return true;
   }

   public void reset_app() {
      
      for (int i = 0; i < total_packet; i++)
	 if (sender[i] != null)
	    sender[i] = null;
      
      base = 0;
      receiver_base = 0;
      nextseq = 0;
      selected = DESELECTED;
      fps = DEFAULT_FPS;
      timerFlag = false;
      timerSleep = false;
      gbnThread = null;
      timerThread = null;
      
      if (stop.getActionCommand() == "startanim") // in case of pause mode,
	 
	 {
	    slow.setEnabled(true);
	    fast.setEnabled(true);
	 }
      
      send.setEnabled(true);
      kill.setEnabled(false);
      stop.setLabel("Pause");
      stop.setActionCommand("stopanim");
      output.append("---------------------------------------------------\n\n");
      output.append("-Simulation restarted. Press 'Send New' to start.\n");
      repaint();
   }
   
}

class GoBackNPacket {
   
   boolean on_way; 
   boolean reached_dest; 
   boolean acknowledged;
   boolean packet_ack; 
   boolean selected; 
   boolean received;
   boolean out_of_order; 
   int packet_pos; 
   int ackFor; 
   boolean buffered;
   
   GoBackNPacket() {
      on_way = false;
      selected = false;
      reached_dest = false;
      acknowledged = false;
      packet_ack = true;
      received = false;
      out_of_order = false;
      packet_pos = 0;
      ackFor = 0;
      buffered = false;
   }
   
   GoBackNPacket(boolean onway, int packetpos, int nextseq) {
      on_way = onway;
      selected = false;
      reached_dest = false;
      acknowledged = false;
      packet_ack = true;
      received = false;
      out_of_order = false;
      packet_pos = packetpos;
      ackFor = nextseq;
      buffered = false;
      
   }
}
