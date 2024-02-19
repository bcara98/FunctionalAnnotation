#!/usr/bin/env python3
import argparse  #parsing argument
import pandas as pd  #data management

def main():

  #parsing argument
  parser = argparse.ArgumentParser()
  parser.add_argument("-g1", help="gff file 1", action='store', type=str, required=True)
  parser.add_argument("-g2", help="gff file 2", action='store', type=str, required=True)
  parser.add_argument("-o", help="output file name", required=True)
  args = parser.parse_args()


  #read files
  df_1 = pd.read_csv(args.g1, sep='\t', skiprows=1,
                     names=["seqname", "source", "feature", "start", "end", "score", "strand", "frame", "attribute"])
  df_2 = pd.read_csv(args.g2, sep='\t', skiprows=1,
                     names=["seqname", "source", "feature", "start", "end", "score", "strand", "frame", "attribute"])


  #change the format to looks like th gff file
  df_1 = change_fmt(df_1)
  df_2 = change_fmt(df_2)

  # call the function for merging
  df_output = merge_gff(df_1, df_2)


  #write output
  #write the header
  with open(args.o,'w') as fh:
    fh.write("##gff-version 3\n")

  #write actual gff file from pandas df
  df_output.to_csv(args.o, index=False, sep='\t', header=False,mode='a')




def change_fmt(df):
  #extract the type of blast

  #change the seqname to the same format
  df[['seqname']] = df[['seqname']].apply(lambda x: '_'.join(x.str.split('_')[0][:-1]) if ':' not in x.values[0] else x.str.split(':').str[0])

  #swap the start and end
  df[['start', 'end']] = df[['start', 'end']].apply(lambda row: row[::-1] if row['end'] < row['start'] else row, axis=1)


  #replace NaN with .
  df.fillna(".", inplace=True)

  #change the attribute
  df.attribute = df.attribute.str.split(";").str[0].tolist()
  return df




def merge_gff(df_1,df_2):
  #select useful columns
  merged_df = pd.merge(df_1, df_2, on=['seqname', 'start', 'end'] ,how='outer',suffixes=("_1","_2"))

  # appending the attribute
  merged_df['attribute'] = merged_df['attribute_1'].fillna("") + ';' + merged_df['attribute_2'].fillna("")
  merged_df['attribute'] = merged_df['attribute'].str.strip(';') #remove the ";", if it is leading...

  #change the source
  merged_df['source'] = '.'
  merged_df.loc[merged_df['source_1'] == merged_df['source_2'], 'source']= merged_df['source_1']
  merged_df['source'] = merged_df['source_1'].combine_first(merged_df['source_2'])


  #change the feature
  merged_df['feature'] = '.'
  merged_df.loc[merged_df['feature_1'] == merged_df['feature_2'], 'feature']= merged_df['feature_1']
  merged_df['feature'] = merged_df['feature_1'].combine_first(merged_df['feature_2'])


  #change the score
  merged_df['score'] = '.'
  merged_df.loc[merged_df['score_1'] == merged_df['score_2'], 'score']= merged_df['score_1']
  merged_df['score'] = merged_df['score_1'].combine_first(merged_df['score_2'])

  #change the strand
  merged_df['strand'] = '.'
  merged_df.loc[merged_df['strand_1'] == merged_df['strand_2'], 'strand']= merged_df['strand_1']
  merged_df['strand'] = merged_df['strand_1'].combine_first(merged_df['strand_2'])


  #change the frame
  merged_df['frame'] = '.'

  # select columns
  merged_df = merged_df[["seqname","source","feature","start","end","score","strand","frame","attribute"]]

  return merged_df


main()




