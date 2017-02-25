require(tcltk)

if1code='IF1509.CFE'  #����
if2code='IF1510.CFE'
gate1b=2;gate1c=1; gate2b=2;gate2c=1;
gcurpos=0;   #��ǰ��λ״̬
printcount=0;#��ӡ������Ϣ

gRunTCLID = 0;

library(WindR)
w.start(0,F);
data<-w.tlogon('0000','0','w081263802','0000','cfe');
if(data$ErrorCode !=0)
{
		print(data);
}
logonid=data$Data$LogonID;

testonce<-function()
{
          a=Sys.time()
          nowdate=as.integer(format(a,'%Y%m%d'))
          nowtime=as.integer(format(a,'%H%M%S'))

					data<-w.wsq(paste(if1code,if2code,sep=','),"rt_date,rt_time,rt_bid1,rt_bsize1,rt_ask1,rt_asize1")
          if(data$ErrorCode!=0)
          {
              print(data);
              gRunTCLID <<-tcl("after", 1000, testonce);
              #Sys.sleep(1);
              return();
          }

					data<-data$Data;
          if(data$RT_DATE[1] != nowdate || nowdate != data$RT_DATE[2] )
          {
              print(data);
              print(nowdate);
              print('date is not same!');
              gRunTCLID <<-tcl("after", 5000, testonce);
              #Sys.sleep(5);
              return();
          }
	
					diff1= data$RT_TIME[1] - data$RT_TIME[2];
					diff2= data$RT_TIME[1] - nowtime;

          if(diff1<10000 || diff1>10000 || diff2<200 || diff2>200 || nowtime<91515 || nowtime>151445 || (nowtime>112945 && nowtime<130000) )
          {
              print(data);
              print(nowtime);
              print('time is not right!');
              gRunTCLID <<-tcl("after", 5000, testonce);
              #Sys.sleep(5);
              return();
          }
          
          if(curpos==0){#û�гֲ�
						if(data$RT_BID1[1] - data$RT_ASK1[2]>gate1b){#���������if1������������if2
							  data<-w.torder(c(if1code,if2code),c('short','buy'),c(data$RT_BID1[1], data$RT_ASK1[2]),c(1,1));
							  print(data);
							  curpos <<- 1;
							  print(paste('���֣�short',if1code, 'at ', data$RT_BID1[1],', buy',if2code,'at data$RT_ASK1[2]'));
		    		}
						if(data$RT_BID1[2] - data$RT_ASK1[1]>gate2b){#���������if2������������if1
							  data<-w.torder(c(if2code,if1code),c('short','buy'),c(data$RT_BID1[2], data$RT_ASK1[1]),c(1,1));
							  print(data);
							  print(paste('���֣�short',if2code, 'at ', data$RT_BID1[2],', buy',if1code,'at data$RT_ASK1[1]'));
							  curpos <<- -1;
		    		}
				 }else if(curpos==1){#�Ѿ�����if1��������if2������ǲ���Ҫƽ��
						if(data$RT_ASK1[1] - data$RT_BID1[2]<gate1c){#������ƽ��if1�������ƽ��if2
								data<-w.torder(c(if1code,if2code),c('cover','sell'),c(data$RT_ASK1[1], data$RT_BID1[2]),c(1,1));
								print(data);
								curpos<<- 0;
								print(paste('ƽ�֣�cover',if1code, 'at ', data$RT_ASK1[1],', sell',if2code,'at data$RT_BID1[2]'));
		    		}
		     }else  if(curpos==-1){#�Ѿ�����if2��������if1������ǲ���Ҫƽ��
						if(data$RT_ASK1[2] - data$RT_BID1[1]<gate2c){#������ƽ��if2�������ƽ��if1
								data<-w.torder(c(if2code,if1code),c('cover','sell'),c(data$RT_ASK1[2], data$RT_BID1[1]),c(1,1));
								print(data);
								curpos<<- 0;
								print(paste('ƽ�֣�cover',if2code, 'at ', data$RT_ASK1[1],', sell',if1code,'at data$RT_BID1[2]'));
		    		}
		     }
		     
				printcount <<- printcount+1;
				if(printcount>80)
				{
					cat('\n');
					cat(paste('price=[',data$RT_BID1[1],data$RT_BID1[2],data$RT_ASK1[1],data$RT_ASK1[2],']'));
					printcount <<- 0;
				}else cat('.');		     
}

stoprun<-function()
{
 		tcl("after", "cancel", gRunTCLID)
}

startrun<-function()
{
		gRunTCLID <<-tcl("after", 1000, testonce);
}