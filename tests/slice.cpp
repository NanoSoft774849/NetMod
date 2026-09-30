#include<stdio.h>
#include<ctype.h>
#include<vector>
#include <cstdint>
#include <stdlib.h>
#include<math.h>
#include<string>
//using namespace std;
using std::vector;
using std::string;
#define MAP_IQ_COMPLEX 0

typedef struct IQ_str 
{
    double i;
    double q;
    int bit_val;
    double scale;
    IQ_str(double _re, double _im)
    {
        this->i  = _re;
        this->q = _im;
         this->bit_val = 0;
        this->scale = 1;
    }
    IQ_str(double _re, double _im, double _scale)
    {
        this->i  = _re / 1;
        this->q = _im / 1;
        this->bit_val = 0;
        this->scale = _scale;
    }
    IQ_str(double _re, double _im, double _scale , int val)
    {

        this->i  = _re / 1;
        this->q = _im / 1;
        this->bit_val = val;
        this->scale = _scale;
    }
    void SetBitValue(int val)
    {
        this->bit_val = val;
    }
    void Update(double _re, double _im)
    {
        this->i  = _re;
        this->q = _im;
    }
    IQ_str & Scale(double scale)
    {
        this-> i = this->i * scale;
        this->q = this->q * scale;
        return *this;
    }
    int ToInt32()
    {
       // return (int) ((this->i)<<16) | (this->q);
       return 0;
    }
    void Print(int idx )
    {
        if( this->q > 0)
        printf(" (%d, 0x%x) : %f + j%f \n ", idx, this->bit_val, this->i, this->q);
        else
        printf(" (%d, 0x%x) : %f - j%f \n ", idx, this->bit_val, this->i, std::abs(this->q));
    }
};


void MSmap(vector<IQ_str> & smap, int bps)
{
    vector<uint8_t> values; 


    int count = ( 1 << bps );
    int  i;
    for( i =0; i < count ; i++)
    {
        values.push_back(i);
    }
    double re;
    double im;
    double scale = 1;
    for( i =0; i < count ; i++)
        {
            int value = values[i];
            int b_0 = (value >> (0)) & 0x1;
            int b_1 = (value >> (1)) & 0x1;
            int b_2 = (value >> (2)) & 0x1;
            int b_3 = (value >> (3)) & 0x1;
            int b_4 = (value >> (4)) & 0x1;
            int b_5 = (value >> (5)) & 0x1;
            int b_6 = (value >> (6)) & 0x1;
            int b_7 = (value >> (7)) & 0x1;

           if( bps == 1)
           {
                re = 1 - 2*b_0;
                im = 1 - 2*b_0;
                scale = std::sqrt(2);
                IQ_str iq(re, im , scale , value);
                smap.push_back(iq);
                continue;
           }
           if( bps == 2)
           {
                re = ( 1 -2*b_0);
                im = ( 1- 2*b_1);
                scale = std::sqrt(2);
                IQ_str iq(re, im , scale , value);
                smap.push_back(iq);
                continue;
           }
           if( bps == 4)
           {
                scale = std::sqrt(10);
                re = ( 1-2*b_0)*( 2 - ( 1- 2*b_2 ));
                im = ( 1-2*b_1)*( 2 - (1 - 2*b_3));
                IQ_str iq(re, im , scale, value);
                smap.push_back(iq);
                continue;
           }
           if( bps == 6)
           {
                scale = std::sqrt(42);
                re = (1 -2*b_0) * ( 4 - (1-2*b_2) ) * ( 2 - (1-2*b_4));
                im = (1 -2*b_1) * ( 4 - (1-2*b_3) ) * ( 2 - (1-2*b_5));
                IQ_str iq(re, im , scale, value);
                smap.push_back(iq);
                continue;
           }
           if( bps == 8) 
           {
                scale = std::sqrt(170);
                re = (1-2*b_0)*(8 -(1-2*b_2))*(4- (1-2*b_4))*(2-(1-2*b_6));
                im = (1-2*b_1)*(8 -(1-2*b_3))*(4- (1-2*b_5))*(2-(1-2*b_7));
                IQ_str iq(re, im , scale , value);
                smap.push_back(iq);
                continue;
           }

          
        }
}

int map( vector<uint16_t> & bs , vector<int> & iq, int bps , vector<int> & smap)
{
    int b_count = bs.size();
    int bits_per_bs_sample = 16; // 16 bits 
    int i =0, k= 0, j=0;
    int rounds_per_sample = (int) (bits_per_bs_sample/ bps);
    uint16_t mask = ( 1 << bps) - 1;
    for( i =0; i < b_count ; i++)
    {
        uint16_t b = bs[i];
        for(  j =0; j <  rounds_per_sample ; j++)
        {
            iq.push_back(smap[b & mask]);
            b = b >> bps;
        }
    }
    return b_count * rounds_per_sample;
}

int mapIQComplex( vector<uint16_t> & bs , vector<IQ_str> & iq, int bps , vector<IQ_str> & smap)
{
    int b_count = bs.size();
    int bits_per_bs_sample = 16; // 16 bits 
    int i =0, k= 0, j=0;
    int rounds_per_sample = (int) (bits_per_bs_sample/ bps);
    uint16_t mask = ( 1 << bps) - 1;
    for( i =0; i < b_count ; i++)
    {
        uint16_t b = bs[i];
        for(  j =0; j <  rounds_per_sample ; j++)
        {
            iq.push_back(smap[b & mask]);
            b = b >> bps;
        }
    }
    return b_count * rounds_per_sample;
}

int mapIQint32( vector<uint16_t> & bs , vector<unsigned int > & iq, int bps , vector<unsigned int> & smap)
{
    int b_count = bs.size();
    int bits_per_bs_sample = 16; // 16 bits 
    int i =0, k= 0, j=0;
    int rounds_per_sample = (int) (bits_per_bs_sample/ bps);
    uint16_t mask = ( 1 << bps) - 1;
    for( i =0; i < b_count ; i++)
    {
        uint16_t b = bs[i];
        for(  j =0; j <  rounds_per_sample ; j++)
        {
            iq.push_back(smap[b & mask]);
            b = b >> bps;
        }
    }
    return b_count * rounds_per_sample;
}

void GenerateSMap(vector<int> & smap, int bps) 
{
    int M = ( 1 << bps);
    for( int i =0; i< M ; i++)
    {
       smap.push_back(i);
    }
}
void Denorm2(unsigned int iq_int, IQ_str & iqx)
{
        double s = 1; //iqx.scale;
        unsigned int scale = ((1 << 10) -1);
        unsigned int  q_norm = iq_int & 0xFFFF;
        unsigned int  i_norm = (iq_int >> 16) & 0xFFFF;

        double i_sign = i_norm >> 15 & 0x1 ? -1 : 1;
        double q_sign = q_norm >> 15 & 0x1 ? -1 : 1;
     

        q_norm = q_norm & 0x7FFF; 
        i_norm = i_norm & 0x7FFF;

        double re = i_norm * 1.0 * i_sign /( s* scale);

        double im = q_norm * 1.0 * q_sign /( s* scale);
        //printf(" re : %f \t im : %f\n", re , im);
        iqx.i = re;
        iqx.q = im;
        iqx.bit_val = 0;

}



void NormalizeIQ32(vector<IQ_str> & iq, vector<unsigned int> & norm)
{
    int count = iq.size();
    int i =0;
    double  scale = ((1 << 10)-1);
    unsigned int mask = ( 1 << 15);
    for( i =0; i< count; i++)
    {
        IQ_str iqx = iq[i];
        double s = iqx.scale;
        //iqx.Scale(s);

        unsigned int sign_i = iqx.i >=0 ? 0: 1;
        unsigned int sign_q = iqx.q >= 0? 0 : 1;

        

        double iqx_i = std::abs(iqx.i) * scale;//* s;
        double iqx_q = std::abs(iqx.q) * scale;//* s;

       // unsigned int I =  (unsigned int) iqx.i;
       // unsigned int Q =  (unsigned int) iqx.q;


        // hex(15)::
        unsigned int i_norm = ((unsigned int) (iqx_i));// & ( 1 << 15);
        unsigned int q_norm = ((unsigned int) (iqx_q));// & ( 1 << 15); 
        i_norm = i_norm | ( sign_i << 15);
        q_norm = q_norm | ( sign_q << 15);

        //printf("i_norm : 0x%x \t q_norm : 0x%x \t, shifted: 0x%x\n ", i_norm , q_norm, (i_norm << 16));

        

        unsigned int cmplx_norm = 0;
        cmplx_norm |= (i_norm << 16);
        cmplx_norm |= (q_norm);
        //printf("0x%x\n", cmplx_norm);
        //IQ_str dnorm(0, 0, s, 0);
        //Denorm2(cmplx_norm, dnorm);
        //dnorm.Print(0);
        //iq[i].Print(i);
        norm.push_back(cmplx_norm);
    }
}

void PrintfOutSmaps(vector<IQ_str> & smap, int bps)
{
    string f_name = "BPSK";
    switch (bps)
    {
    case 1 : 
        f_name = f_name;
        break;
    case 2:
     f_name = "QPSK";
    break;
    case 4:
     f_name = "QAM16";
    break;
    case 6:
     f_name = "QAM64";
    break;
    case 8:
     f_name = "QAM256";
    break;
    default:
        break;
    }
    f_name = f_name + ".txt";
    vector<unsigned int> out;
    NormalizeIQ32(smap, out);
    
    int size = out.size();
   
    string file_name = "../setup/"+ f_name;
    printf("file path : %s \n", file_name.c_str());
    FILE * fp = fopen(file_name.c_str(), "w+");
    for( int i =0; i< size ; i++)
    {
        fprintf(fp, "0x%x\n", out[i]);
    }
    fclose(fp);
}

int main(int argc, char **argv)
{
    vector<uint16_t> bytes = { 0x1234, 0x5678, 0xBADC,0xFE10, 0x9988, 0x7766, 0xaabb, 0xccdd, 0x1020, 0x3040, 0x1011,0x1213, 0x1122,0x3344, 0x5566,0x7788 };

    int bps = 1;
    if( argc == 2)
    {
        bps = atoi(argv[1]);
    }
    #if MAP_IQ_COMPLEX == 1
    vector<IQ_str> SMAP; 
    vector<unsigned int> iq;
    vector<unsigned int> iq_int;
    MSmap(SMAP, bps);
    //PrintfOutSmaps(SMAP, bps);
    NormalizeIQ32(SMAP, iq_int);

    int count =  mapIQint32(bytes, iq, bps, iq_int);
    for ( int i =0 ; i < count ; i++)
    {
        unsigned int s = iq[i];
        // change them to bytes
        printf(" (%d) ", i);
       for( int j =0 ; j < 4 ; j++)
       {
            int sx = (s >> (8*(3-j))) & 0xFF;
            printf(" %02x ", sx);
       }
       printf("\n");
    }
    #else 

    vector<IQ_str> SMAP; 
    //vector<int> iq;

    //GenerateSMap(SMAP, bps);
    MSmap(SMAP, bps);
    int count = SMAP.size();
    //int count =  map(bytes, iq, bps, SMAP);
    for ( int i =0 ; i < count ; i++)
    {
       SMAP[i].Print(i);
    }

    #endif
    return 0;
}