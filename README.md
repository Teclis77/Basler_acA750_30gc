To Compile the IOC, it's necessary:
1) Install ADGenICam e ADPylon
cd /path/to/areaDetector
git clone https://github.com/areaDetector/ADGenICam
git clone https://github.com/areaDetector/ADPylon
cd ADGenICam && make
cd ../ADPylon && make

2) configure the RELEASE

3) Install Pylon
To install the pylon Software Suite in /opt/pylon, follow these steps:
  1. Change to the directory that contains the pylon_*.tar.gz archive that
     you downloaded from the Basler website.
  2. Extract the pylon Software Suite into /opt/pylon:
      sudo mkdir /opt/pylon
      sudo tar -C /opt/pylon -xzf ./pylon_*.tar.gz
  3. Change access rights of the pylon folder:
      sudo chmod 755 /opt/pylon
  4. in /opt/pylon, install the package:
      sudo dnf install ./codemeter*.rpm

4) cd /path/to/temp
SU TERMINALE
# Compile to extract l'XML

cat > getxml.cpp << 'EOF'
#include <pylon/PylonIncludes.h>
#include <iostream>
#include <fstream>
using namespace Pylon;
using namespace std;
int main() {
    PylonInitialize();
    try {
        CInstantCamera camera(CTlFactory::GetInstance().CreateFirstDevice());
        camera.Open();
        GenICam::gcstring xmlData;
        CFeaturePersistence::SaveToString(xmlData, &camera.GetNodeMap());
        ofstream f("/path/to/temp/acA750-30gc.xml");
        f << xmlData;
        f.close();
        cout << "XML saved!" << endl;
        camera.Close();
    } catch (const GenericException &e) {
        cerr << "Error: " << e.GetDescription() << endl;
    }
    PylonTerminate();
    return 0;
}
EOF
Se non ci sono errori (sempre da terminale)
source /opt/pylon/bin/pylon-setup-env.sh /opt/pylon

***
g++ getxml.cpp -o getxml \
    -I/opt/pylon/include \
    -L/opt/pylon/lib \
    -lpylonbase -lpylonc -lpylonutility \
    -lGenApi_gcc_v3_5_Basler_pylon_v1 -lGCBase_gcc_v3_5_Basler_pylon_v1 \
    -Wl,-rpath,/opt/pylon/lib

***

./getxml
***

cd /path/to/ADGenICam
python3 scripts/makeDb.py \
    xml/Basler-acA640-300gm.xml \
    GenICamApp/Db/Basler-acA750-30gc.template

make

cp GenICamApp/Db/Basler-acA750-30gc.template /to/path/Basler_acA750-folder/db

5) If necessary, optimize the Etho-net
Etho card should be at least 1 Gbps
	ethtool eno2 | grep Speed
Optimized Pytlon 
	sudo /opt/pylon/bin/PylonGigEConfigurator auto-opt


	sudo sysctl -p
	sudo ethtool -G eno2 rx 2040 rx-jumbo 8160
	sudo ip link set eno2 mtu 9000
Permission in memory
	sudo bash -c 'echo "* hard memlock unlimited" >> /etc/security/limits.conf'
	sudo bash -c 'echo "* soft memlock unlimited" >> /etc/security/limits.conf'
