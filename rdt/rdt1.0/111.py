# -*- coding: utf-8 -*-
"""
Created on Tue May  7 17:59:31 2019

@author: Administrator
"""

import com.ouc.tcp.client.TCP_Sender_ADT;
import com.ouc.tcp.message.*;
import com.ouc.tcp.tool.TCP_TOOL;
public class TCP_Sender extends TCP_Sender_ADT {
    private TCP_PACKET tcpPack; 
    public TCP_Sender() {
        super(); 
        super.initTCP_Sender(this); 
    }
    public void rdt_send(int dataIndex, int[] appData) {
        tcpH.setTh_seq(dataIndex * appData.length + 1);
        tcpS.setData(appData);
        tcpPack = new TCP_PACKET(tcpH, tcpS , destinAddr);
        udt_send(tcpPack);
        waitACK();
    }
    public void udt_send(TCP_PACKET tcpPack) {
        tcpH.setTh_eflag((byte)0); 
        client.send(tcpPack);
    }
    public void waitACK() {
        while(true) {
            if(!ackQueue.isEmpty() && ackQueue.poll() == tcpPack.getTcpH().getTh_seq()) {
                break;
            }
        }
    }
    public void recv(TCP_PACKET recvPack) {
        ackQueue.add(recvPack.getTcpH().getTh_ack());
        System.out.println();
    }
}
    
    
    
    
    
    
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import com.ouc.tcp.client.TCP_Receiver_ADT;
import com.ouc.tcp.message.*;
import com.ouc.tcp.tool.TCP_TOOL;
public class TCP_Receiver extends TCP_Receiver_ADT {
    private TCP_PACKET ackPack; 
    public TCP_Receiver() {
        super();
        super.initTCP_Receiver(this); 
    }

    public void rdt_recv(TCP_PACKET recvPack) {

        tcpH.setTh_ack(recvPack.getTcpH().getTh_seq());
        ackPack = new TCP_PACKET(tcpH, tcpS, recvPack.getSourceAddr());

        reply(ackPack);

        dataQueue.add(recvPack.getTcpS().getData());

        if(dataQueue.size() == 20) {
            deliver_data();
        }
        System.out.println();
    }
}
